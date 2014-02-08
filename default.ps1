properties {
  $cwd = Resolve-Path .
  $xunitRunner = "$cwd\packages\xunit.runners.1.9.2\tools\xunit.console.clr4.exe"
}

Task -name Build -action {
  Exec {
    msbuild Allan.EntityFramework.sln /p:Configuration=Release
  }
};

Task -name UnitTest -depend Build -action {
  Mkdir TestResults
  Exec {
    & $xunitRunner ".\Allan.UnitTests\bin\Debug\Allan.UnitTests.dll" /nunit TestResults\Allan.UnitTests.xml
  }
}

Task -name Default -depends Build
