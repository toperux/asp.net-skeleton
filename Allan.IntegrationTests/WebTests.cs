using Xunit;
using OpenQA.Selenium;
using OpenQA.Selenium.IE;

namespace Allan.IntegrationTests
{
    public class WebTests
    {
        [Fact]
        public void HomePage_ByDefault_ReturnsHelloWorld()
        {
            IWebDriver browser = new InternetExplorerDriver();

            browser.Navigate().GoToUrl("http://localhost:8080");
            string result = browser.PageSource;
            browser.Quit();

            Assert.Contains("Hello World", result);
        }
    }
}
