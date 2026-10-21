import SwiftUI

/// How many grid columns a card spans.
private nonisolated struct CardSpanKey: LayoutValueKey {
    static let defaultValue = 1
}

/// Packs cards into rows like tiles on a console home screen. A card that
/// doesn't fit starts a new row; the last card of a row stretches to close the
/// gap. Cards in a row share the tallest card's height.
struct CardGridLayout: Layout {
    var columns: Int
    var spacing: CGFloat

    private struct Row {
        var items: [(index: Int, span: Int)] = []
        var used = 0
    }

    private func rows(_ subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var row = Row()
        for (index, subview) in subviews.enumerated() {
            let span = min(max(subview[CardSpanKey.self], 1), columns)
            if row.used + span > columns, !row.items.isEmpty {
                rows.append(row)
                row = Row()
            }
            row.items.append((index, span))
            row.used += span
        }
        if !row.items.isEmpty { rows.append(row) }
        // Stretch the last card so a row never ends with a gap.
        for i in rows.indices where rows[i].used < columns {
            let last = rows[i].items.count - 1
            rows[i].items[last].span += columns - rows[i].used
            rows[i].used = columns
        }
        return rows
    }

    private func columnWidth(_ width: CGFloat) -> CGFloat {
        (width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
    }

    private func width(span: Int, column: CGFloat) -> CGFloat {
        column * CGFloat(span) + spacing * CGFloat(span - 1)
    }

    private func height(_ row: Row, _ subviews: Subviews, column: CGFloat) -> CGFloat {
        row.items.map { item in
            subviews[item.index].sizeThatFits(ProposedViewSize(width: width(span: item.span, column: column), height: nil)).height
        }.max() ?? 0
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let total = proposal.width ?? 360
        let column = columnWidth(total)
        let rows = rows(subviews)
        let heights = rows.map { height($0, subviews, column: column) }
        let sum = heights.reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
        return CGSize(width: total, height: sum)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let column = columnWidth(bounds.width)
        var y = bounds.minY
        for row in rows(subviews) {
            let rowHeight = height(row, subviews, column: column)
            var x = bounds.minX
            for item in row.items {
                let w = width(span: item.span, column: column)
                subviews[item.index].place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: w, height: rowHeight)
                )
                x += w + spacing
            }
            y += rowHeight + spacing
        }
    }
}

extension CardSize {
    /// Columns a card spans: two columns on iPhone, four on iPad.
    func span(columns: Int) -> Int {
        switch self {
        case .small: 1
        case .medium: columns >= 4 ? 2 : columns
        case .large: columns
        }
    }

    var title: String {
        switch self {
        case .small: L("Klein")
        case .medium: L("Mittel")
        case .large: L("Groß")
        }
    }
}

/// Cards the student can resize, reorder (drag or arrows), hide and add back.
/// `editing` is driven by an "Anpassen" button in the screen's toolbar.
struct CustomizableCardGrid<Kind, Content: View>: View
where Kind: Codable & Hashable & Sendable & CaseIterable & RawRepresentable, Kind.RawValue == String {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var slots: [CardSlot<Kind>]
    var editing: Bool
    var title: (Kind) -> String
    var symbol: (Kind) -> String
    var save: ([CardSlot<Kind>]) -> Void
    @ViewBuilder var content: (Kind, CardSize) -> Content

    private var columns: Int { sizeClass == .regular ? 4 : 2 }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.spacingL) {
            CardGridLayout(columns: columns, spacing: DS.spacingL) {
                ForEach(slots, id: \.kind) { slot in
                    content(slot.kind, slot.size)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .allowsHitTesting(!editing)
                        .overlay { if editing { editOverlay(slot) } }
                        .scaleEffect(editing && !reduceMotion ? 0.97 : 1)
                        .animation(reduceMotion ? nil : .spring(duration: 0.3), value: editing)
                        .draggable(slot.kind.rawValue)
                        .dropDestination(for: String.self) { items, _ in
                            guard editing, let raw = items.first, let moved = Kind(rawValue: raw) else { return false }
                            move(moved, before: slot.kind)
                            return true
                        }
                        .layoutValue(key: CardSpanKey.self, value: slot.size.span(columns: columns))
                }
            }
            .animation(reduceMotion ? nil : .spring(duration: 0.35), value: slots)
            if editing {
                hiddenCards
            }
        }
    }

    private func editOverlay(_ slot: CardSlot<Kind>) -> some View {
        RoundedRectangle(cornerRadius: DS.cardRadius, style: .continuous)
            .strokeBorder(Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
            .overlay(alignment: .topTrailing) {
                HStack(spacing: DS.spacingXS) {
                    Menu {
                        Picker(L("Größe"), selection: Binding(
                            get: { slot.size },
                            set: { resize(slot.kind, to: $0) }
                        )) {
                            ForEach(CardSize.allCases) { size in
                                Text(size.title).tag(size)
                            }
                        }
                        Button(L("Nach vorne"), systemImage: "arrow.up.left") { shift(slot.kind, by: -1) }
                        Button(L("Nach hinten"), systemImage: "arrow.down.right") { shift(slot.kind, by: 1) }
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .frame(width: 32, height: 32)
                    }
                    .accessibilityLabel(L("Größe und Position"))
                    Button(L("Ausblenden"), systemImage: "minus") { hide(slot.kind) }
                        .labelStyle(.iconOnly)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.glass)
                .padding(DS.spacingS)
            }
    }

    @ViewBuilder
    private var hiddenCards: some View {
        let hidden = Array(Kind.allCases).filter { kind in !slots.contains { $0.kind == kind } }
        if !hidden.isEmpty {
            VStack(alignment: .leading, spacing: DS.spacingS) {
                Text(L("Ausgeblendete Karten"))
                    .font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.spacingS) {
                        ForEach(hidden, id: \.self) { kind in
                            Button {
                                save(slots + [CardSlot(kind: kind, size: .medium)])
                            } label: {
                                Label(title(kind), systemImage: symbol(kind))
                            }
                            .buttonStyle(.glass)
                        }
                    }
                }
            }
        }
    }

    private func resize(_ kind: Kind, to size: CardSize) {
        var list = slots
        guard let i = list.firstIndex(where: { $0.kind == kind }) else { return }
        list[i].size = size
        save(list)
    }

    private func shift(_ kind: Kind, by delta: Int) {
        var list = slots
        guard let i = list.firstIndex(where: { $0.kind == kind }) else { return }
        let target = min(max(i + delta, 0), list.count - 1)
        list.swapAt(i, target)
        save(list)
    }

    private func move(_ kind: Kind, before target: Kind) {
        guard kind != target else { return }
        var list = slots
        guard let from = list.firstIndex(where: { $0.kind == kind }) else { return }
        let slot = list.remove(at: from)
        let to = list.firstIndex(where: { $0.kind == target }) ?? list.count
        list.insert(slot, at: to)
        save(list)
    }

    private func hide(_ kind: Kind) {
        save(slots.filter { $0.kind != kind })
    }
}

/// The toolbar button that switches a card screen into edit mode.
struct CustomizeButton: View {
    @Binding var editing: Bool

    var body: some View {
        Button(editing ? L("Fertig") : L("Anpassen"), systemImage: editing ? "checkmark" : "square.grid.2x2") {
            withAnimation { editing.toggle() }
        }
    }
}
