---
applyTo: '**/*.ps1,**/*.psm1'
description: 'PowerShell cmdlet and scripting best practices for Windows automation and cmdlet development'
---

# PowerShell Development Guidelines

Comprehensive PowerShell instructions combining Microsoft cmdlet development guidelines with practical Windows setup, optimization, and automation patterns. Target PowerShell 7+ when possible; maintain 5.1 compatibility when required.

## General Principles

- **PowerShell Version**: Target PowerShell 7+ when possible; note 5.1 differences if backward compatibility required
- **Brace Style**: OTBS (One True Brace Style) - opening brace on same line
- **Indentation**: 2-space indentation (per `.vscode/settings.json`)
- **Dependencies**: Prefer built-in cmdlets; avoid external dependencies
- **Code Reuse**: Centralize shared logic in modules (e.g., `Scripts/Common.ps1`); avoid duplication
- **Non-Interactive**: Design for automation; avoid `Read-Host` in scripts
- **Base Paths**: Use `$PSScriptRoot` for relative paths; never assume current directory

## Naming Conventions

### Verb-Noun Format
- Use approved PowerShell verbs (`Get-Verb` to list)
- Use singular nouns (e.g., `Get-User`, not `Get-Users`)
- PascalCase for both verb and noun
- Avoid special characters and spaces

### Parameter Names
- Use PascalCase
- Choose clear, descriptive names
- Use singular form unless always multiple
- Follow PowerShell standard names (`Path`, `Name`, `Force`, `ComputerName`)

### Variable Names
- **PascalCase**: Public/exported variables and parameters
- **camelCase**: Private/local variables
- **ALL_CAPS**: Constants
- Avoid abbreviations; use meaningful names

### Alias Avoidance
- Use full cmdlet names in scripts (no `gci`, `?`, `%`, `where`)
- Full parameter names (no `-Recurse` → `-r`)
- Aliases acceptable for interactive shell only
- Document any custom aliases

### Examples

```powershell
# ✅ Good
function Get-UserProfile {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [string]$Username,
    
    [Parameter()]
    [ValidateSet('Basic', 'Detailed')]
    [string]$ProfileType = 'Basic'
  )
  
  process {
    $userInfo = Get-ADUser -Identity $Username
    # Logic here
  }
}

# ❌ Bad - aliases, unclear names
function GetUsrProf($u) {
  $usr = Get-ADUser $u | select *
  dir HKLM:\Software | ? {$_.Name -like "*$u*"}
}
```

## Parameter Design

### Standard Parameters
- Use common parameter names (`Path`, `Name`, `Force`, `ComputerName`)
- Follow built-in cmdlet conventions
- Use parameter sets for mutually exclusive options
- Enable tab completion with `ValidateSet`

### Type Selection
- Use common .NET types (`[string]`, `[int]`, `[datetime]`)
- Implement proper validation attributes
- Use `[ValidateSet()]` for limited options
- Use `[ValidateScript()]` for complex validation
- Use `[ValidateNotNullOrEmpty()]` for required strings

### Switch Parameters
- Use `[switch]` for boolean flags
- Avoid `[bool]` parameters (use switch instead)
- Default to `$false` when omitted
- Use clear action names (`Force`, `Recurse`, `PassThru`)

### Validation Attributes
```powershell
function Set-ResourceConfiguration {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Name,
    
    [Parameter()]
    [ValidateSet('Dev', 'Test', 'Prod')]
    [string]$Environment = 'Dev',
    
    [Parameter()]
    [ValidateRange(1, 100)]
    [int]$Priority = 50,
    
    [Parameter()]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$Path,
    
    [Parameter()]
    [switch]$Force,
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string[]]$Tags
  )
  
  process {
    # Logic here
  }
}
```

## Pipeline and Output

### Pipeline Input
- Use `ValueFromPipeline` for direct object input
- Use `ValueFromPipelineByPropertyName` for property mapping
- Implement Begin/Process/End blocks for pipeline handling
- Process one object at a time in `process` block

### Output Objects
- Return rich objects (`PSCustomObject`), not formatted text
- Avoid `Write-Host` for data output (use for UI only)
- Enable downstream cmdlet processing
- Use consistent property names across cmdlets

### Pipeline Streaming
- Output one object at a time (don't collect large arrays)
- Use `process` block for streaming
- Avoid `@()` array collection when possible
- Enable immediate downstream processing

### PassThru Pattern
- Default to no output for action cmdlets (Set/New/Remove)
- Implement `-PassThru` switch for object return
- Return modified/created object with `-PassThru`
- Use `Write-Verbose`/`Write-Warning` for status updates

### Examples

```powershell
function Update-ResourceStatus {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string]$Name,
    
    [Parameter(Mandatory)]
    [ValidateSet('Active', 'Inactive', 'Maintenance')]
    [string]$Status,
    
    [Parameter()]
    [switch]$PassThru
  )
  
  begin {
    Write-Verbose 'Starting resource status update process'
    $timestamp = Get-Date
  }
  
  process {
    Write-Verbose "Processing resource: $Name"
    
    # Perform update
    $resource = [PSCustomObject]@{
      PSTypeName  = 'CustomResource'
      Name        = $Name
      Status      = $Status
      LastUpdated = $timestamp
      UpdatedBy   = $env:USERNAME
    }
    
    # Only output if PassThru is specified
    if ($PassThru.IsPresent) {
      Write-Output $resource
    }
  }
  
  end {
    Write-Verbose 'Resource status update process completed'
  }
}

# Usage
Get-ChildItem -Path 'C:\Resources' |
  Where-Object {$_.Extension -eq '.xml'} |
  Update-ResourceStatus -Status 'Active' -PassThru |
  Format-Table -AutoSize
```

## Error Handling and Safety

### ShouldProcess Implementation
- Use `[CmdletBinding(SupportsShouldProcess = $true)]` for system changes
- Set appropriate `ConfirmImpact` level (Low/Medium/High)
- Call `$PSCmdlet.ShouldProcess()` before destructive operations
- Use `ShouldContinue()` for additional confirmations

### Error Handling Pattern
- Set `$ErrorActionPreference = 'Stop'` at script/function start
- Use `try/catch/finally` blocks for error management
- Catch specific exception types (avoid bare `catch`)
- In `[CmdletBinding()]` functions:
  - Prefer `$PSCmdlet.WriteError()` over `Write-Error`
  - Prefer `$PSCmdlet.ThrowTerminatingError()` over `throw`
- Construct proper `ErrorRecord` objects with category, target, and exception
- Provide clear, actionable error messages

### Message Streams
- `Write-Verbose`: Operational details (enabled with `-Verbose`)
- `Write-Warning`: Warning conditions (always shown)
- `Write-Information`: Informational messages (PS 5+)
- `Write-Error`: Non-terminating errors
- `throw` or `$PSCmdlet.ThrowTerminatingError()`: Terminating errors
- Avoid `Write-Host` except for user interface text

### Example

```powershell
function Remove-UserAccount {
  [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
  param(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string]$Username,
    
    [Parameter()]
    [switch]$Force
  )
  
  begin {
    Write-Verbose 'Starting user account removal process'
    $ErrorActionPreference = 'Stop'
  }
  
  process {
    try {
      # Validation
      if (-not (Test-UserExists -Username $Username)) {
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
          [System.Exception]::new("User account '$Username' not found"),
          'UserNotFound',
          [System.Management.Automation.ErrorCategory]::ObjectNotFound,
          $Username
        )
        $PSCmdlet.WriteError($errorRecord)
        return
      }
      
      # Confirmation
      $shouldProcessMessage = "Remove user account '$Username'"
      if ($Force -or $PSCmdlet.ShouldProcess($Username, $shouldProcessMessage)) {
        Write-Verbose "Removing user account: $Username"
        
        # Main operation
        Remove-ADUser -Identity $Username -ErrorAction Stop
        Write-Warning "User account '$Username' has been removed"
      }
    }
    catch [Microsoft.ActiveDirectory.Management.ADException] {
      $errorRecord = [System.Management.Automation.ErrorRecord]::new(
        $_.Exception,
        'ActiveDirectoryError',
        [System.Management.Automation.ErrorCategory]::NotSpecified,
        $Username
      )
      $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
    catch {
      $errorRecord = [System.Management.Automation.ErrorRecord]::new(
        $_.Exception,
        'UnexpectedError',
        [System.Management.Automation.ErrorCategory]::NotSpecified,
        $Username
      )
      $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
  }
  
  end {
    Write-Verbose 'User account removal process completed'
  }
}
```

## Performance Optimization

### Pipeline Efficiency
- Minimize pipeline overhead in hot paths
- Prefer bulk operations over per-item processing
- Use `.ForEach()` method over `ForEach-Object` for arrays
- Use `.Where()` method over `Where-Object` for filtering

### Avoid Overhead
- Avoid unnecessary subshells and `Invoke-Expression`
- Don't use `Write-Host` in loops (adds overhead)
- Minimize `Get-Command`/`Get-Module` calls in loops
- Cache repeated cmdlet lookups

### File I/O
- Use `Get-Content -Raw` for reading entire files
- Use `Set-Content -NoNewline` when appropriate
- Prefer `-Encoding UTF8` (without BOM) for configs
- Use `System.IO.File` for large files or performance-critical paths

### Examples

```powershell
# ❌ Slow - pipeline overhead
$files = Get-ChildItem -Recurse
$filtered = $files | Where-Object {$_.Extension -eq '.log'}
$results = $filtered | ForEach-Object {$_.Length}

# ✅ Fast - method calls
$files = Get-ChildItem -Recurse
$filtered = $files.Where({$_.Extension -eq '.log'})
$results = $filtered.ForEach({$_.Length})

# ❌ Slow - repeated calls
foreach ($item in $items) {
  Get-Date | Out-File -Append log.txt
}

# ✅ Fast - batch operations
$timestamp = Get-Date
$items | ForEach-Object {"$timestamp : $_"} | Out-File log.txt
```

## Filesystem and Paths

### Path Handling
- Use `Join-Path` for path construction (never string concatenation)
- Use `Resolve-Path` for absolute paths
- Use `Test-Path` before operations
- Base relative paths on `$PSScriptRoot`, not current directory

### Encoding
- Be explicit: `-Encoding UTF8` (default in PS 7+)
- UTF8 without BOM for configs (unless specific requirement)
- UTF8 with BOM for PowerShell scripts if cross-platform issues

### Examples

```powershell
# ✅ Good - proper path handling
$scriptDir = $PSScriptRoot
$configPath = Join-Path -Path $scriptDir -ChildPath 'config.json'

if (Test-Path -Path $configPath) {
  $config = Get-Content -Path $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
}

# ❌ Bad - string concatenation, assumes current directory
$configPath = ".\config.json"
if (Test-Path $configPath) {
  $config = Get-Content $configPath | ConvertFrom-Json
}
```

## Registry and System Tweaks

### Idempotent Operations
- Check current state before making changes
- Use `Test-Path` before `New-Item`/`Set-ItemProperty`
- Compare existing values to avoid unnecessary writes
- Support `-WhatIf` for preview mode

### Registry Safety
- Guard registry edits with backups or confirmations
- Use full paths (`HKLM:\`, `HKCU:\`)
- Create parent keys before setting values
- Handle missing keys gracefully

### Examples

```powershell
function Set-RegistryValue {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory)]
    [string]$KeyPath,
    
    [Parameter(Mandatory)]
    [string]$Name,
    
    [Parameter(Mandatory)]
    [object]$Value,
    
    [Parameter()]
    [ValidateSet('String', 'DWord', 'QWord', 'Binary', 'MultiString', 'ExpandString')]
    [string]$Type = 'String'
  )
  
  $ErrorActionPreference = 'Stop'
  
  # Create key if missing
  if (-not (Test-Path -Path $KeyPath)) {
    if ($PSCmdlet.ShouldProcess($KeyPath, 'Create registry key')) {
      New-Item -Path $KeyPath -Force | Out-Null
      Write-Verbose "Created registry key: $KeyPath"
    }
  }
  
  # Check current value
  $currentValue = Get-ItemProperty -Path $KeyPath -Name $Name -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty $Name
  
  # Only set if different
  if ($currentValue -ne $Value) {
    if ($PSCmdlet.ShouldProcess("$KeyPath\$Name", "Set value to '$Value'")) {
      Set-ItemProperty -Path $KeyPath -Name $Name -Value $Value -Type $Type -Force
      Write-Verbose "Set $KeyPath\$Name = $Value"
    }
  }
  else {
    Write-Verbose "Value already set: $KeyPath\$Name = $Value"
  }
}

# Usage
Set-RegistryValue -KeyPath 'HKCU:\Software\MyApp' -Name 'Setting1' -Value 'Enabled' -WhatIf
```

## Documentation and Style

### Comment-Based Help
Include comment-based help for all public functions. Place inside function body:

```powershell
function Get-SystemInfo {
  <#
  .SYNOPSIS
    Retrieves system information including OS, hardware, and network details.
  
  .DESCRIPTION
    The Get-SystemInfo cmdlet collects comprehensive system information from local
    or remote computers. It returns a custom object with structured data suitable
    for reporting or further processing.
  
  .PARAMETER ComputerName
    Specifies the computer name(s) to query. Defaults to local computer.
  
  .PARAMETER IncludeNetwork
    Includes detailed network adapter information in the output.
  
  .EXAMPLE
    Get-SystemInfo
    
    Retrieves system information for the local computer.
  
  .EXAMPLE
    Get-SystemInfo -ComputerName SERVER01, SERVER02 -IncludeNetwork
    
    Retrieves system and network information from two remote computers.
  
  .OUTPUTS
    PSCustomObject
    Returns a custom object with OS, hardware, and network properties.
  
  .NOTES
    Requires administrative privileges for remote queries.
    Compatible with PowerShell 5.1 and 7+.
  #>
  [CmdletBinding()]
  param(
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string[]]$ComputerName = $env:COMPUTERNAME,
    
    [Parameter()]
    [switch]$IncludeNetwork
  )
  
  process {
    # Implementation
  }
}
```

### Consistent Formatting
- **Indentation**: 2 spaces
- **Braces**: Opening brace on same line (OTBS)
- **Line breaks**: After pipeline operators for readability
- **Whitespace**: Space after commas, around operators
- **Parameter blocks**: Align attributes vertically

```powershell
# ✅ Good formatting
function Process-Data {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [string]$InputPath,
    
    [Parameter()]
    [switch]$Force
  )
  
  begin {
    $ErrorActionPreference = 'Stop'
  }
  
  process {
    $data = Get-Content -Path $InputPath |
      Where-Object {$_ -match '^\d+'} |
      ForEach-Object {$_.Trim()} |
      Sort-Object
    
    if ($Force -or (Test-Condition)) {
      Write-Output $data
    }
  }
}

# ❌ Bad formatting - inconsistent spacing, poor alignment
function Process-Data{
[CmdletBinding()]
param([Parameter(Mandatory)][string]$InputPath,[switch]$Force)
begin{$ErrorActionPreference='Stop'}
process{
$data=Get-Content -Path $InputPath|Where-Object{$_ -match '^\d+'}|ForEach-Object{$_.Trim()}|Sort-Object
if($Force -or(Test-Condition)){Write-Output $data}}}
```

## Code Reuse and Shared Logic

### Centralized Helpers
- Create shared module (e.g., `Scripts/Common.ps1`)
- Import with `Import-Module -Force` at script start
- Avoid duplicating common functions
- Use dot-sourcing for simple helper scripts

### Example Common Module

```powershell
# Scripts/Common.ps1

function Test-IsAdmin {
  <#
  .SYNOPSIS
    Tests if current session has administrator privileges.
  #>
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal]$identity
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-AdminElevation {
  <#
  .SYNOPSIS
    Requests elevation to administrator if not already elevated.
  #>
  if (-not (Test-IsAdmin)) {
    $scriptPath = $MyInvocation.PSCommandPath
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -File `"$scriptPath`""
    exit
  }
}

function Write-ColorOutput {
  <#
  .SYNOPSIS
    Writes colored output to console.
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [string]$Message,
    
    [Parameter()]
    [ConsoleColor]$ForegroundColor = 'White'
  )
  
  Write-Host $Message -ForegroundColor $ForegroundColor
}

Export-ModuleMember -Function *
```

### Using Shared Module

```powershell
# Main script
[CmdletBinding()]
param()

# Import common functions
$commonPath = Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1'
Import-Module $commonPath -Force

# Use shared functions
Request-AdminElevation

Write-ColorOutput -Message 'Starting setup...' -ForegroundColor Green

# Rest of script
```

## Validation and Testing

### Linting
```powershell
# Install PSScriptAnalyzer
Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force

# Run analysis
Invoke-ScriptAnalyzer -Path . -Recurse -Settings PSGallery

# Fix automatically (where possible)
Invoke-ScriptAnalyzer -Path script.ps1 -Fix
```

### Testing Workflow
1. **WhatIf First**: Run with `-WhatIf` to preview changes
2. **Non-Admin Test**: Verify detection and elevation requests
3. **Admin Test**: Verify actual operations work correctly
4. **Error Paths**: Test with invalid inputs and missing resources
5. **Exit Codes**: Verify `$LASTEXITCODE` for external commands

### Example Test Cases

```powershell
# Test script with WhatIf
.\Setup-System.ps1 -WhatIf

# Test non-admin behavior
runas /trustlevel:0x20000 "powershell.exe -File .\Setup-System.ps1"

# Test error handling
.\Process-File.ps1 -Path 'C:\NonExistent\file.txt' -ErrorAction Stop

# Verify idempotency
.\Configure-Registry.ps1
.\Configure-Registry.ps1  # Should not make changes second time
```

## Full Example: Complete Cmdlet

```powershell
function New-ConfigurationFile {
  <#
  .SYNOPSIS
    Creates a new configuration file with specified settings.
  
  .DESCRIPTION
    The New-ConfigurationFile cmdlet creates a JSON configuration file with
    the provided settings. It supports validation, backup, and idempotent operation.
  
  .PARAMETER Path
    Specifies the path where the configuration file will be created.
  
  .PARAMETER Settings
    Hashtable of settings to include in the configuration.
  
  .PARAMETER Force
    Overwrites existing file without prompting.
  
  .PARAMETER BackupExisting
    Creates a backup of existing file before overwriting.
  
  .PARAMETER PassThru
    Returns the created configuration object.
  
  .EXAMPLE
    $settings = @{
      ServerName = 'localhost'
      Port = 8080
      EnableSSL = $true
    }
    New-ConfigurationFile -Path 'C:\config\app.json' -Settings $settings
    
    Creates a new configuration file with the specified settings.
  
  .EXAMPLE
    New-ConfigurationFile -Path 'C:\config\app.json' -Settings $settings -Force -PassThru
    
    Overwrites existing file and returns the configuration object.
  
  .OUTPUTS
    PSCustomObject (when -PassThru is specified)
    Returns the configuration object that was written to file.
  
  .NOTES
    Requires write permissions to the target directory.
    Creates parent directory if it doesn't exist.
  #>
  [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string]$Path,
    
    [Parameter(Mandatory)]
    [ValidateNotNull()]
    [hashtable]$Settings,
    
    [Parameter()]
    [switch]$Force,
    
    [Parameter()]
    [switch]$BackupExisting,
    
    [Parameter()]
    [switch]$PassThru
  )
  
  begin {
    Write-Verbose 'Starting configuration file creation process'
    $ErrorActionPreference = 'Stop'
  }
  
  process {
    try {
      # Resolve full path
      $fullPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
      $directory = Split-Path -Path $fullPath -Parent
      
      # Create directory if needed
      if (-not (Test-Path -Path $directory)) {
        if ($PSCmdlet.ShouldProcess($directory, 'Create directory')) {
          New-Item -Path $directory -ItemType Directory -Force | Out-Null
          Write-Verbose "Created directory: $directory"
        }
      }
      
      # Handle existing file
      if (Test-Path -Path $fullPath) {
        if (-not $Force -and -not $PSCmdlet.ShouldProcess($fullPath, 'Overwrite existing file')) {
          Write-Warning "File exists and -Force not specified: $fullPath"
          return
        }
        
        # Backup if requested
        if ($BackupExisting) {
          $backupPath = "$fullPath.bak"
          Copy-Item -Path $fullPath -Destination $backupPath -Force
          Write-Verbose "Created backup: $backupPath"
        }
      }
      
      # Create configuration object
      $config = [PSCustomObject]@{
        PSTypeName = 'ConfigurationFile'
        Created    = Get-Date
        Settings   = $Settings
      }
      
      # Write to file
      if ($PSCmdlet.ShouldProcess($fullPath, 'Write configuration file')) {
        $config | ConvertTo-Json -Depth 10 | Set-Content -Path $fullPath -Encoding UTF8 -Force
        Write-Verbose "Created configuration file: $fullPath"
      }
      
      # Return object if PassThru
      if ($PassThru.IsPresent) {
        Write-Output $config
      }
    }
    catch [System.UnauthorizedAccessException] {
      $errorRecord = [System.Management.Automation.ErrorRecord]::new(
        $_.Exception,
        'AccessDenied',
        [System.Management.Automation.ErrorCategory]::PermissionDenied,
        $fullPath
      )
      $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
    catch {
      $errorRecord = [System.Management.Automation.ErrorRecord]::new(
        $_.Exception,
        'ConfigurationCreationFailed',
        [System.Management.Automation.ErrorCategory]::NotSpecified,
        $fullPath
      )
      $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
  }
  
  end {
    Write-Verbose 'Configuration file creation process completed'
  }
}
```

## Common Patterns

### Elevation Detection and Request
```powershell
function Request-AdminElevation {
  $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  
  if (-not $isAdmin) {
    $scriptPath = $MyInvocation.PSCommandPath
    Write-Warning 'Administrator privileges required. Requesting elevation...'
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    exit
  }
}
```

### Progress Reporting
```powershell
$total = $items.Count
$current = 0

foreach ($item in $items) {
  $current++
  $percentComplete = ($current / $total) * 100
  
  Write-Progress -Activity 'Processing Items' -Status "Item $current of $total" -PercentComplete $percentComplete
  
  # Process item
  Process-Item -Item $item
}

Write-Progress -Activity 'Processing Items' -Completed
```

### Confirmation Prompts
```powershell
$title = 'Confirm Action'
$message = 'Are you sure you want to proceed?'
$yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Proceed with action'
$no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Cancel action'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.UI.PromptForChoice($title, $message, $options, 1)

if ($result -eq 0) {
  # User chose Yes
  Write-Host 'Proceeding...'
}
```

## Maintenance

### Regular Updates
- Update when shared modules (`Common.ps1`) change
- Re-test scripts after Windows/driver updates
- Review and update examples for current PowerShell version
- Validate PSScriptAnalyzer rules compliance
- Test with both PowerShell 5.1 and 7+ if targeting both

### Compatibility Notes
- **PowerShell 7+**: UTF8 default, new operators (`??`, `?:`, `&&`, `||`)
- **PowerShell 5.1**: UTF8 with BOM, older syntax
- Test cross-platform if targeting Windows/Linux/macOS
- Document minimum required version in help
