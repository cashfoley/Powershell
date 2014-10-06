$BuildToolsFolder = 'C:\SVN\BuildConfigurations'

$Env:JAVA_HOME = Join-Path $BuildToolsFolder 'Java\jdk1.7.0_51'
$Env:MAVEN_HOME = Join-Path $BuildToolsFolder 'Maven\apache-maven-3.2.1'
$Env:M2 = Join-Path $Env:MAVEN_HOME 'bin'

Add-Path $Env:M2
Add-Path (Join-Path $Env:JAVA_HOME 'bin')
