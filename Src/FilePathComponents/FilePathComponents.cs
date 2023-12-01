namespace VSYSStructs
{
    public class FilePathComponents
    {
        public FilePathComponents() { }
        public string? Folder { get; set; }
        public string? FileBase { get; set; }
        public string? File { get; set; }
        public string? FileExtension { get; set; }
        public string? FullPathNoExtension { get; set; }
        public string? FullPath { get; set; }
        public string? ParentFolder { get; set; }
    }
}
