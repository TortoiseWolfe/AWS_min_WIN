Add-Type -AssemblyName PresentationFramework

$window = New-Object System.Windows.Window
$window.Title = "Modal Dialog"
$window.SizeToContent = "WidthAndHeight"
$window.WindowStartupLocation = "CenterScreen"

$label = New-Object System.Windows.Controls.Label
$label.Content = "This is a modal dialog box."

$button = New-Object System.Windows.Controls.Button
$button.Content = "OK"
$button.Add_Click({ $window.DialogResult = $true })

$stackPanel = New-Object System.Windows.Controls.StackPanel
$stackPanel.Children.Add($label)
$stackPanel.Children.Add($button)

$window.Content = $stackPanel
$window.ShowDialog() | Out-Null
