# Creates a local user named visitor
# Removes visitor from the default Users group
# Adds visitor to Guests group
# Ensures visitor will never be required to set/change a password

net user "Visitor" /add
net localgroup Users "Visitor" /delete
net localgroup Guests "Visitor" /add
Set-LocalUser -Name Visitor -PasswordNeverExpires $true

# ref:
#   - https://www.laptopmag.com/articles/create-guest-account-windows-10