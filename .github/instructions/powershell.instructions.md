---
applyTo: '**/*.ps1,**/*.psm1'
description: 'PowerShell cmdlet development and Windows automation best practices'
---

# PowerShell Guidelines

**Target:** PowerShell 7+ (note 5.1 compat if needed) | **Style:** OTBS, 2-space indent | **Deps:** Prefer built-in cmdlets

## Naming

- **Verb-Noun**: Approved verbs (`Get-Verb`), singular nouns, PascalCase
- **Parameters**: PascalCase, standard names (`Path`, `Name`, `Force`, `ComputerName`)
- **Variables**: PascalCase (public), camelCase (private), ALL_CAPS (constants)
- **No Aliases**: Full cmdlet/parameter names in scripts (aliases OK in interactive shell)

```powershell
# ✅ Good
function Get-UserProfile {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Username,

    [ValidateSet('Basic', 'Detailed')]
    [string]$ProfileType = 'Basic'
  )
  process { $userInfo = Get-ADUser -Identity $Username }
}

# ❌ Bad
function GetUsrProf($u) {
  gci HKLM:\Software | ? {$_.Name -like "*$u*"}
}
```

## Parameters

- **Types**: Use .NET types (`[string]`, `[int]`, `[datetime]`)
- **Validation**: `[ValidateSet()]`, `[ValidateScript()]`, `[ValidateNotNullOrEmpty()]`
- **Switches**: Use `[switch]` for booleans (not `[bool]`)
- **Pipeline**: `ValueFromPipeline`, `ValueFromPipelineByPropertyName`

```powershell
param(
  [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
  [ValidateNotNullOrEmpty()]
  [string]$Name,

  [ValidateSet('Dev', 'Test', 'Prod')]
  [string]$Environment = 'Dev',

  [ValidateRange(1, 100)]
  [int]$Priority = 50,

  [ValidateScript({Test-Path $_ -PathType Container})]
  [string]$Path,

  [switch]$Force
)
```

## Pipeline & Output

- **Begin/Process/End**: Use for pipeline handling
- **Objects**: Return `PSCustomObject`, not formatted text
- **Streaming**: Output one object at a time in `process` block
- **PassThru**: Return object after modification when `-PassThru` specified

```powershell
function Process-Item {
  [CmdletBinding()]
  param(
    [Parameter(ValueFromPipeline)]
    [string[]]$Name,
    [switch]$PassThru
  )
  begin { $count = 0 }
  process {
    foreach ($item in $Name) {
      # Process
      $count++
      if ($PassThru) {
        [PSCustomObject]@{
          Name = $item
          Status = 'Processed'
        }
      }
    }
  }
  end { Write-Verbose "Processed $count items" }
}
```

## Error Handling

```powershell
function Invoke-SafeOperation {
  [CmdletBinding()]
  param([string]$Path)

  try {
    $ErrorActionPreference = 'Stop'
    $result = Get-Item -Path $Path
    return $result
  }
  catch [System.IO.FileNotFoundException] {
    Write-Error "File not found: $Path"
    return $null
  }
  catch {
    Write-Error "Unexpected error: $_"
    throw
  }
}
```

## Performance

- **Pipeline**: Stream objects, don't collect in arrays
- **StringBuilder**: For string concatenation in loops
- **Where-Object**: Use `.Where({})` method for large collections
- **ForEach-Object**: Use `.ForEach({})` method for better performance
- **Measure**: Use `Measure-Command` to profile

```powershell
# ❌ Slow
$items = Get-ChildItem -Recurse
$filtered = $items | Where-Object {$_.Extension -eq '.txt'}

# ✅ Fast
$filtered = (Get-ChildItem -Recurse).Where({$_.Extension -eq '.txt'})
```

## Module Structure

```powershell
# MyModule.psm1
$Public = @(Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1")
$Private = @(Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1")

foreach ($import in @($Public + $Private)) {
  try { . $import.FullName }
  catch { Write-Error "Failed to import $($import.FullName): $_" }
}

Export-ModuleMember -Function $Public.BaseName
```

## Advanced Functions

```powershell
function Set-Configuration {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
  param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [string]$Name,

    [ValidateNotNullOrEmpty()]
    [hashtable]$Settings,

    [switch]$Force
  )

  begin {
    Write-Verbose "Starting configuration update"
  }

  process {
    if ($PSCmdlet.ShouldProcess($Name, 'Update configuration')) {
      try {
        # Apply settings
        Write-Verbose "Updated $Name"
      }
      catch {
        Write-Error "Failed to update $Name: $_"
      }
    }
  }

  end {
    Write-Verbose "Configuration update complete"
  }
}
```

## Testing (Pester)

```powershell
Describe 'Get-UserProfile' {
  BeforeAll {
    Mock Get-ADUser { [PSCustomObject]@{Name='TestUser'} }
  }

  It 'Returns user profile' {
    $result = Get-UserProfile -Username 'test'
    $result.Name | Should -Be 'TestUser'
  }

  It 'Validates username parameter' {
    { Get-UserProfile -Username '' } | Should -Throw
  }
}
```

## Security

- **Credentials**: Use `[PSCredential]`, never plain text
- **SecureStrings**: For passwords/secrets
- **Constrained Language**: Support for restricted environments
- **Input Validation**: Always validate external input

```powershell
function Connect-Service {
  param(
    [Parameter(Mandatory)]
    [PSCredential]$Credential,

    [ValidateScript({$_ -match '^https://'})]
    [string]$Uri
  )

  # Use credential securely
}
```

## Common Patterns

**Splatting:**
```powershell
$params = @{
  Path = 'C:\Temp'
  Recurse = $true
  Filter = '*.log'
}
Get-ChildItem @params
```

**Calculated Properties:**
```powershell
Get-Process | Select-Object Name, @{
  Name = 'MemoryMB'
  Expression = {[math]::Round($_.WorkingSet / 1MB, 2)}
}
```

**Hash Tables:**
```powershell
$config = @{
  Server = 'prod-srv01'
  Port = 443
  EnableSSL = $true
  Tags = @('production', 'web')
}
```

## Windows-Specific

**Registry:**
```powershell
$regPath = 'HKLM:\SOFTWARE\MyApp'
if (!(Test-Path $regPath)) {
  New-Item -Path $regPath -Force
}
Set-ItemProperty -Path $regPath -Name 'Version' -Value '1.0'
```

**Services:**
```powershell
Get-Service -Name 'MyService' |
  Where-Object {$_.Status -eq 'Running'} |
  Stop-Service -Force -PassThru
```

**Event Logs:**
```powershell
Get-EventLog -LogName Application -EntryType Error -Newest 10
```

## Style Guide

- OTBS braces (opening on same line)
- 2-space indentation
- `$PSScriptRoot` for relative paths
- `[CmdletBinding()]` for advanced functions
- `Write-Verbose` for diagnostic output
- `Write-Error` for non-terminating errors
- `throw` for terminating errors
- Comment-based help (`<#`, `#>`)

## Checklist

- [ ] Verb-Noun naming with approved verbs
- [ ] `[CmdletBinding()]` on functions
- [ ] Parameter validation attributes
- [ ] Pipeline support (Begin/Process/End)
- [ ] Return objects (not formatted text)
- [ ] Error handling (try/catch)
- [ ] `SupportsShouldProcess` for state changes
- [ ] Comment-based help
- [ ] Pester tests
- [ ] No aliases in scripts
