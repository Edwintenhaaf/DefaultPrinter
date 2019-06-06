#RES Like default printer screen
#Edwin ten Haaf T4Change

#get current default printer
$Default = Get-WmiObject -Query " SELECT * FROM Win32_Printer WHERE Default=$true" | select Name,Location

#get list of printers
$Printers = Get-Printer

#error check in case there are no printers
if (!$Printers) {

[System.Windows.MessageBox]::Show('No Printers found, please install one first!','No Default printer','OK','Error') 
exit
}

#Build windows
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Icon
#$Icon                            = New-Object system.drawing.icon ('path to icon')
#$Form.Icon                       = $Icon
$Icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + '\powershell.exe')
$form.Icon = $Icon

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Printer Selection v0.1'
$form.Size = New-Object System.Drawing.Size(400,350)
$form.StartPosition = 'CenterScreen'                   # CenterScreen, Manual, WindowsDefaultLocation, WindowsDefaultBounds, CenterParent
$Form.Opacity = 0.9                                    # 1.0 is fully opaque; 0.0 is invisible

#$font = New-Object System.Drawing.Font("Times New Roman",12,[System.Drawing.FontStyle]::Italic) # Font styles are: Regular, Bold, Italic, Underline, Strikeout
#$form.Font = $font


$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,250)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,250)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(20,20)
$label.Size = New-Object System.Drawing.Size(210,18)
$label.Text = 'Please select a default printer!'
$form.Controls.Add($label)

if ($Default.Name) {
$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(20,60)
$label2.Size = New-Object System.Drawing.Size(350,18)
$label2.ForeColor = 'Red'
$label2.Text = 'Current default: '+$Default.Name
$form.Controls.Add($label2)
    }

#Show location if available
If ($Default.Location) {
$label3 = New-Object System.Windows.Forms.Label
$label3.Location = New-Object System.Drawing.Point(20,80)
$label3.Size = New-Object System.Drawing.Size(350,18)
$label3.ForeColor = 'Red'
$label3.Text = 'Location: '+$Default.Location
$form.Controls.Add($label3)
    }

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(20,100)
$listBox.Size = New-Object System.Drawing.Size(250,5)
$listBox.Height = 130

#Fill listbox with current printers
ForEach ($Printer in $Printers)
{
[void] $listBox.Items.Add($Printer.Name)
}

$form.Controls.Add($listBox)
$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    
$selection = $listBox.SelectedItem

If($selection){
    #set selection as default printer 
    (Get-WmiObject -ComputerName . -Class Win32_Printer -Filter "Name='$selection'").SetDefaultPrinter() | Out-Null
    
    #check new default
    $NewDefault = Get-WmiObject -Query " SELECT * FROM Win32_Printer WHERE Default=$true" | select Name
    #[System.Windows.MessageBox]::Show('default printer set to: '+$selection,'Default printer','OK','Info')
    
      } 
    Else 
    { 
        [System.Windows.MessageBox]::Show('Oeps, er ging iets mis!','Default printer','OK','Error') 
    } 
}
