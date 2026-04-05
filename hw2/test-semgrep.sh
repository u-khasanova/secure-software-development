#!/usr/bin/env bash
set -e

RULES_FILE="semgrep-rules.yaml"
UNSAFE_DIR="test_cases/unsafe"
SAFE_DIR="test_cases/safe"
REPORT_FILE="semgrep-report.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

setup_test_files() {
    mkdir -p "$UNSAFE_DIR" "$SAFE_DIR"
    cat > "$UNSAFE_DIR/unsafe_examples.cs" << 'UNSAFE_EOF'
using System;
using System.IO;
using MetadataExtractor;
using UglyToad.PdfPig;
using AngleSharp;
using AngleSharp.Html.Parser;
using System.Xml;

namespace UnsafeExamples
{
    public class UnsafeMetadataExtractor
    {
        public void ExtractJpegUnsafe(string filePath)
        {
            var metadata = ImageMetadataReader.ReadMetadata(filePath);
            Console.WriteLine($"Date: {metadata}");
        }

        public void ExtractPngUnsafe(Stream stream)
        {
            var metadata = ImageMetadataReader.ReadMetadata(stream);
        }

        public void ExtractPdfUnsafe(Stream pdfStream)
        {
            using var doc = PdfDocument.Open(pdfStream);
            var title = doc.Information.Title;
        }

        public void ExtractSvgUnsafe(Stream svgStream)
        {
            var config = Configuration.Default;
            var context = BrowsingContext.New(config);
            var doc = context.OpenAsync(svgStream).Result;
        }

        public void ParseSvgWithXmlReaderUnsafe(Stream svgStream)
        {
            var settings = new XmlReaderSettings();
            using var reader = XmlReader.Create(svgStream, settings);
        }

        public void ExtractWithReadAllBytesUnsafe(string filePath)
        {
            var bytes = File.ReadAllBytes(filePath);
            using var ms = new MemoryStream(bytes);
            var metadata = ImageMetadataReader.ReadMetadata(ms);
        }

        public void ExtractWithErrorLeak(string filePath)
        {
            try
            {
                var metadata = ImageMetadataReader.ReadMetadata(filePath);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                Console.WriteLine($"Stack: {ex.StackTrace}");
            }
        }

        public void ExtractWithoutTimeout(Stream stream)
        {
            var metadata = ImageMetadataReader.ReadMetadata(stream);
        }
    }
}
UNSAFE_EOF
}

run_unsafe_tests() {
    local unsafe_results
    unsafe_results=$(semgrep --config "$RULES_FILE" "$UNSAFE_DIR" --json --quiet 2>/dev/null || true)
    local unsafe_count
    unsafe_count=$(echo "$unsafe_results" | jq -r '.results | length')
    return 0
}

main() {
    setup_test_files
    local exit_code=0
    if ! run_unsafe_tests; then
        log_error "Тесты на небезопасном коде не пройдены"
        exit_code=1
    fi
    if [[ $exit_code -eq 0 ]]; then
        log_info "Все тесты пройдены успешно"
        semgrep --config "$RULES_FILE" "$UNSAFE_DIR" "$SAFE_DIR" --json > "$REPORT_FILE" 2>/dev/null || true
        log_info "Отчёт сохранён в $REPORT_FILE"
    fi
    
    rm -rf "$UNSAFE_DIR" "$SAFE_DIR"
    exit $exit_code
}

main "$@"