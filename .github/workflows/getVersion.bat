for /F %%i in ('python .github/workflows/getVersion.py') do (set Version=%%i)
echo Version=%Version% >> $env:GITHUB_ENV