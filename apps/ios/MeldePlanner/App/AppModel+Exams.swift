import Foundation
import PDFKit
import UIKit

/// Prüfungen & Scans: PDFs stored in the app's protected container, metadata in AppData.
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
        ExamFiles.folder()?.appending(path: exam.fileName)
    }

    /// Stores the PDF and records the exam.
    @discardableResult
    func addExam(pdf: Data, title: String, subjectID: UUID?, date: Date, grade: String, notes: String) throws(ExamError) -> ExamDocument {
        guard let document = PDFDocument(data: pdf) else { throw .unreadablePDF }
        let id = UUID()
        let fileName = "\(id.uuidString).pdf"
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
    static func folder() -> URL? {
        guard let base = try? FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        ) else { return nil }
        let folder = base.appending(path: "MeldePlanner/Exams", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    /// Builds a PDF from scanned pages, downscaled and JPEG-compressed so a
    /// multi-page Klausur stays a few MB.
    static func pdf(from images: [UIImage]) -> Data? {
        let document = PDFDocument()
        for (index, image) in images.enumerated() {
            let scaled = downscale(image, maxSide: 2200)
            guard let page = PDFPage(image: scaled, options: [.compressionQuality: 0.6]) else { continue }
            document.insert(page, at: index)
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
