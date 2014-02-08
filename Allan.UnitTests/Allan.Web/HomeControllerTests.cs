using Xunit;

using Allan.Web.Controllers;

namespace Allan.UnitTests.Allan.Web
{
    public class HomeControllerTests
    {
        [Fact]
        public void Index_ByDefault_ReturnsHelloWorld()
        {
            HomeController home = new HomeController();

            var result = home.Index();

            Assert.Equal("Hello World", result);
        }
    }
}
