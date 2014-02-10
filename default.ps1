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
    & $xunitRunner ".\Allan.UnitTests\bin\Debug\Allan.UnitTests.dll" /nunit $cwd\TestResults\Allan.UnitTests.xml
  }
}

Task -name IntegrationTest -action {
  Mkdir Artifacts
  Exec {
    msbuild Allan.Web\Allan.Web.csproj /t:PipelineDeployPhase /p:Configuration=Release /p:PublishProfile=Testing /p:ArtifactDir=$cwd\Artifacts
  }
  $iis = Start-Job -ScriptBlock { & "c:\Program Files\IIS Express\iisexpress.exe" $args} -ArgumentList "/path:$cwd\Artifacts\"
  Mkdir TestResults
  & $xunitRunner ".\Allan.IntegrationTests\bin\Debug\Allan.IntegrationTests.dll" /nunit $cwd\TestResults\Allan.IntegrationTests.xml
  Stop-Job $iis
  Receive-Job $iis
}

Task -name Default -depends Build
