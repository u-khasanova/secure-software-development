using System;
using System.IO;
using MetadataExtractor;
using UglyToad.PdfPig;
using UglyToad.PdfPig.Documents;
using AngleSharp.Html.Dom;
using AngleSharp.Html.Parser;
using AngleSharp;
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

        public void ExtractWithoutSignatureCheck(Stream stream)
        {
            var metadata = ImageMetadataReader.ReadMetadata(stream);
        }
    }
}