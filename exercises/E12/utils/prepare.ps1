$dcTesting = [ADSI]"LDAP://DC=testing,DC=local"
$ouIW2 = $dcTesting.Create("OrganizationalUnit", "OU=IW2")
$ouIW2.SetInfo()

$userA = $ouIW2.Create("user", "CN=UserA")
$userA.Put("sAMAccountName", "UserA") 
$userA.SetInfo()
$userA.SetPassword("aaaAAA111")
$userA.SetInfo()
$userA.InvokeSet("AccountDisabled", $false)
$userA.SetInfo()

$userA = $ouIW2.Create("user", "CN=UserB")
$userA.Put("sAMAccountName", "UserB") 
$userA.SetInfo()
$userA.SetPassword("aaaAAA111")
$userA.SetInfo()
$userA.InvokeSet("AccountDisabled", $false)
$userA.SetInfo()

$ouIW2 = [ADSI]"LDAP://OU=IW2,DC=testing,DC=local"
$ouIW2.deleteTree()
