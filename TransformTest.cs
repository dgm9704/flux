namespace flux
{
    using System.Xml.Xsl;
    using Xunit;

    public class TransformTest
    {
        [Fact]
        public void BooksTest()
        {
            XslCompiledTransform xslt = new XslCompiledTransform();
            xslt.Load("output.xsl");
            xslt.Transform("books.xml", "books.html");
        }

        [Fact]
        public void AifmTest()
        {
            XslCompiledTransform xslt = new XslCompiledTransform();
            xslt.Load("aifm.xsl");
            xslt.Transform("aifmsample.xml", "aifmoutput.txt");
        }

        [Fact]
        public void AifTest()
        {
            XslCompiledTransform xslt = new XslCompiledTransform();
            xslt.Load("aif.xsl");
            xslt.Transform("aifsample.xml", "aifoutput.txt");
        }

    }
}
