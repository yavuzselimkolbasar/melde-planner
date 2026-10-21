import Foundation
import PDFKit
import UIKit

/// Prüfungen & Scans: PDFs in Documents/Prüfungen (visible in the Files app
/// under "Auf meinem iPhone › Meldo"), metadata in AppData.
extension AppModel {
    enum ExamError: Error {
        case unreadablePDF
        case storage
    }

    /// Sorted newest first.
    var exams: [ExamDocument] {
        data.exams.sorted { $0.date > $1.date }
    }

    func fileURL(for exam: ExamDocument) -> URL? {
        ExamFiles.locate(exam.fileName)
    }

    /// Stores the PDF and records the exam.
    @discardableResult
    func addExam(pdf: Data, title: String, subjectID: UUID?, date: Date, grade: String, notes: String) throws(ExamError) -> ExamDocument {
        guard let document = PDFDocument(data: pdf) else { throw .unreadablePDF }
        let id = UUID()
        let subjectName = subjectID.flatMap { subject($0)?.name }
        let fileName = ExamFiles.readableName(title: title, subject: subjectName, date: date, id: id)
        guard let url = ExamFiles.folder()?.appending(path: fileName) else { throw .storage }
        do {
            try pdf.write(to: url, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        } catch {
            throw .storage
        }
        let exam = ExamDocument(
            id: id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? L("Prüfung") : title,
            subjectID: subjectID, date: date, fileName: fileName,
            pageCount: document.pageCount, grade: grade, notes: notes
        )
        mutate { $0.exams.append(exam) }
        return exam
    }

    func update(_ exam: ExamDocument) {
        var exam = exam
        exam.updatedAt = currentDate
        mutate { data in
            if let i = data.exams.firstIndex(where: { $0.id == exam.id }) { data.exams[i] = exam }
        }
    }

    func deleteExam(_ id: UUID) {
        if let exam = data.exams.first(where: { $0.id == id }), let url = fileURL(for: exam) {
            try? FileManager.default.removeItem(at: url)
        }
        mutate { $0.exams.removeAll { $0.id == id } }
    }
}

enum ExamFiles {
    /// Documents/Prüfungen: the app shares its Documents folder with the Files app.
    static func folder() -> URL? {
        guard let base = try? FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        ) else { return nil }
        let folder = base.appending(path: "Prüfungen", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    /// Version 0.2 kept PDFs hidden in Application Support.
    private static func legacyFolder() -> URL? {
        try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appending(path: "MeldePlanner/Exams", directoryHint: .isDirectory)
    }

    /// The PDF's location; a file from an older version is moved into the
    /// Files-visible folder the first time it's opened.
    static func locate(_ fileName: String) -> URL? {
        guard let target = folder()?.appending(path: fileName) else { return nil }
        let manager = FileManager.default
        if !manager.fileExists(atPath: target.path(percentEncoded: false)),
           let old = legacyFolder()?.appending(path: fileName),
           manager.fileExists(atPath: old.path(percentEncoded: false)) {
            try? manager.moveItem(at: old, to: target)
        }
        return target
    }

    /// "Mathematik – 2. Klassenarbeit (12.10.2026).pdf", unique per exam.
    static func readableName(title: String, subject: String?, date: Date, id: UUID) -> String {
        let day = date.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year().locale(Localization.locale))
        let parts = [subject, title.trimmingCharacters(in: .whitespacesAndNewlines)].compactMap { $0 }.filter { !$0.isEmpty }
        let base = (parts.isEmpty ? L("Prüfung") : parts.joined(separator: " – ")) + " (\(day))"
        let unsafe = CharacterSet(charactersIn: "/\\:?%*|\"<>").union(.newlines)
        var safe = base.components(separatedBy: unsafe).joined(separator: "-")
        while safe.hasPrefix(".") { safe.removeFirst() }
        var name = "\(safe).pdf"
        if let folder = folder(), FileManager.default.fileExists(atPath: folder.appending(path: name).path(percentEncoded: false)) {
            name = "\(safe) \(id.uuidString.prefix(4)).pdf"
        }
        return name
    }

    /// Builds a PDF from scanned pages, downscaled and JPEG-compressed so a
    /// multi-page Klausur stays a few MB.
    static func pdf(from images: [UIImage]) -> Data? {
        let document = PDFDocument()
        for image in images {
            let scaled = downscale(image, maxSide: 2200)
            guard let page = PDFPage(image: scaled, options: [.compressionQuality: 0.6]) else { continue }
            // Append: a skipped image must not leave a gap in the page indices.
            document.insert(page, at: document.pageCount)
        }
        return document.pageCount > 0 ? document.dataRepresentation() : nil
    }

    private static func downscale(_ image: UIImage, maxSide: CGFloat) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > maxSide else { return image }
        let factor = maxSide / longest
        let size = CGSize(width: image.size.width * factor, height: image.size.height * factor)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
