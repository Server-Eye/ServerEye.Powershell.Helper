<#

    .DESCRIPTION
    Create a new Server-Eye Password Vault

    .PARAMETER showPassword
    Is it possible to show the Password in plain text

    .PARAMETER authenticationMethod
    Which Method should be use to encrypt the Vault

    .PARAMETER showPassword
    Is it possible to show the Password in plain text

    .PARAMETER name
    Name of the Vault

    .PARAMETER description
    description of the Vault

    .PARAMETER userId
    ID of the User the Vault will be crated for, can not be used with customerId or distributorId

    .PARAMETER customerId
    ID of the Customer the Vault will be crated for, can not be used with userId or distributorId

    .PARAMETER distributorId
    ID of the distributor the Vault will be crated for, can not be used with userId or customerId

    .PARAMETER PathToSaveKey
    Path where the RestoreKey for the Vault should be stored

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>
function New-Vault {
    [CmdletBinding(DefaultParameterSetName = "byUserID")]
    Param ( 
        [Parameter(Mandatory = $false, ParameterSetName = "byUserID")]
        [Parameter(Mandatory = $false, ParameterSetName = "byCustomerId")]
        [Parameter(Mandatory = $false, ParameterSetName = "byDistributorId")]
        [bool]$showPassword = $false,
        [Parameter(Mandatory = $true, ParameterSetName = "byUserID")]
        [Parameter(Mandatory = $true, ParameterSetName = "byCustomerId")]
        [Parameter(Mandatory = $true, ParameterSetName = "byDistributorId")]
        [ValidateSet("PASSWORD", "KEY_FILE")]
        $authenticationMethod,
        [Parameter(Mandatory = $true, ParameterSetName = "byUserID")]
        [Parameter(Mandatory = $true, ParameterSetName = "byCustomerId")]
        [Parameter(Mandatory = $true, ParameterSetName = "byDistributorId")]
        $name,
        [Parameter(Mandatory = $true, ParameterSetName = "byUserID")]
        [Parameter(Mandatory = $true, ParameterSetName = "byCustomerId")]
        [Parameter(Mandatory = $true, ParameterSetName = "byDistributorId")]
        $description,
        [Parameter(Mandatory = $false, ParameterSetName = "byUserID")]
        $userId,
        [Parameter(Mandatory = $false, ParameterSetName = "byCustomerId")]
        $customerId,
        [Parameter(Mandatory = $false, ParameterSetName = "byDistributorId")]
        $distributorId,
        [Parameter(Mandatory = $false, ParameterSetName = "byUserID")]
        [Parameter(Mandatory = $false, ParameterSetName = "byCustomerId")]
        [Parameter(Mandatory = $false, ParameterSetName = "byDistributorId")]
        $PathToSaveKey,
        [Parameter(Mandatory = $false, ParameterSetName = "byUserID")]
        [Parameter(Mandatory = $false, ParameterSetName = "byCustomerId")]
        [Parameter(Mandatory = $false, ParameterSetName = "byDistributorId")]
        [alias("ApiKey", "Session")]
        $AuthToken
    )

    begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    Process {
        $reqBody = @{  
            'showPassword'         = $showPassword
            'authenticationMethod' = $authenticationMethod
            'name'                 = $name
            'description'          = $description
            'userId'               = $userId
            'customerId'           = $customerId
            'distributorId'        = $distributorId

        }

        $url = "https://api-ms.server-eye.de/3/vault"

        $Result = Intern-PostJson -url $url -body $reqBody -authtoken $AuthToken

        $TypeName = if ($Result.distributorId) { 
            "distributor" 
        }
        elseif ($Result.customerId) { 
            "customer" 
        }
        elseif ($result.userId) { 
            "User" 
        }
        $ID = if ($Result.distributorId) { 
            $Result.distributorId 
        }
        elseif ($Result.customerId) {
            $Result.customerId 
        }
        elseif ($result.userId) { 
            $result.userId 
        }

        $type = [PSCustomObject]@{
            TypeName = $TypeName
            ID       = $ID
        }

        [PSCustomObject]@{
            Name                 = $result.Name
            VaultID              = $result.ID
            Description          = $Result.description
            AuthenticationMethod = $Result.authenticationMethod
            Users                = $Result.users
            Entries              = $Result.entries
            Type                 = $type
            ShowPassword         = $Result.showPassword
            restoreKey           = $Result.restoreKey
        }
        try {
            Out-File -FilePath "$PathToSaveKey\$name-Restorekey.txt"  -Encoding utf8 -InputObject $Result.restoreKey 
        }
        catch {
            Write-Error -Message "Something went wrong: $_"
        }


    }

    End {

    }

}
# SIG # Begin signature block
# MIIkVQYJKoZIhvcNAQcCoIIkRjCCJEICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCD1LFGJE2/TaCI9
# 9LQ3G906AobmSy+8TH/M+cCOqsvTNKCCHkQwggVAMIIEKKADAgECAhA+ii5iHolI
# oJc0Gy3BlHV8MA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# ExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoT
# D1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBTaWdu
# aW5nIENBMB4XDTIxMDMxNTAwMDAwMFoXDTIzMDMxNTIzNTk1OVowgacxCzAJBgNV
# BAYTAkRFMQ4wDAYDVQQRDAU2NjU3MTERMA8GA1UECAwIU2FhcmxhbmQxEjAQBgNV
# BAcMCUVwcGVsYm9ybjEZMBcGA1UECQwQS29zc21hbnN0cmFzc2UgNzEiMCAGA1UE
# CgwZS3LDpG1lciBJVCBTb2x1dGlvbnMgR21iSDEiMCAGA1UEAwwZS3LDpG1lciBJ
# VCBTb2x1dGlvbnMgR21iSDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
# APZ99rk9dw3vm2ll7CstRVSY1Z4ZQowm7j0cN1jaFsKGMR/fnntgILwKHrP4nAfV
# DD5fnaZQW9U7GCJBddLNWNPiRJ/MGRbSJ3S1WHBJYbKzx+tqXmug/k/YwYNjG6wL
# V+wLCOMFaxa2wkFPcgdIjRF9mE5BT81QgB0ip32AH3TA9DYGX/ElSiw03qQpNz3k
# 1mwvtuv+pcr6vP4c/Zv0UMlKcKhheaVlDOc1pu4mYcqSDKW79CwbLlR4MtEfkcgR
# J5vhNhXPYUrx2Q11MA1jQtoprM9fkA8xx68jxMvvoJJW3OvcbnNU/obvMKKCNex/
# 6vQn5yrdfWdX5IFz03QNNCECAwEAAaOCAZAwggGMMB8GA1UdIwQYMBaAFA7hOqhT
# OjHVir7Bu61nGgOFrTQOMB0GA1UdDgQWBBS/o2hdxTj7XrAgvfi7QIWvYGQFezAO
# BgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcD
# AzARBglghkgBhvhCAQEEBAMCBBAwSgYDVR0gBEMwQTA1BgwrBgEEAbIxAQIBAwIw
# JTAjBggrBgEFBQcCARYXaHR0cHM6Ly9zZWN0aWdvLmNvbS9DUFMwCAYGZ4EMAQQB
# MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwuc2VjdGlnby5jb20vU2VjdGln
# b1JTQUNvZGVTaWduaW5nQ0EuY3JsMHMGCCsGAQUFBwEBBGcwZTA+BggrBgEFBQcw
# AoYyaHR0cDovL2NydC5zZWN0aWdvLmNvbS9TZWN0aWdvUlNBQ29kZVNpZ25pbmdD
# QS5jcnQwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqG
# SIb3DQEBCwUAA4IBAQAqIfS4ob0wDVC1CQV0qlo/mnO6yxubYVuCbBmIx6KZM8pE
# 2OZebVcVh1t82nqYdmulFHs878F35iCi2Vls8eTNhrptNLGp+JTAD5bhV1x9obDD
# 02TsqgSysmMoqav0sP8vIJdsHuR/12wzy9HDt8invvHWjBeIa8Yq7breoSepnAPn
# 99lt0q2QYCWHGef7uj3pRSMyD+Hef0zERRcCuORZJp+mJDctSRwMQ8MzWlNpg1oG
# M4qQqntIVEDRduegGO5IF1n3Dtx/lSoh2WWL+1PO8aNsmrvQK4Xw6S2VEWZvAipu
# 9MdCunys05wHRkG2QCSgCY4S/Z2jswLbA9ATGMxJMIIFjTCCBHWgAwIBAgIQDpsY
# jvnQLefv21DiCEAYWjANBgkqhkiG9w0BAQwFADBlMQswCQYDVQQGEwJVUzEVMBMG
# A1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQw
# IgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcNMjIwODAxMDAw
# MDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGln
# aUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhE
# aWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKnJS7JIT3yithZwuEppz1Yq3aaza57
# G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/WBTxSD1Ifxp4VpX6+n6lXFllVcq9o
# k3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHiLQwb7iDVySAdYyktzuxeTsiT+CFh
# mzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhmV1efVFiODCu3T6cw2Vbuyntd463J
# T17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHEtWoYOAMQjdjUN6QuBX2I9YI+EJFw
# q1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6MUSaM0C/CNdaSaTC5qmgZ92kJ7yh
# Tzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mXaXpI8OCiEhtmmnTK3kse5w5jrubU
# 75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZxd9LBADMfRyVw4/3IbKyEbe7f/LV
# jHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfhvbfmQ6QYuKZ3AeEPlAwhHbJUKSWJ
# bOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvlEFDrMcXKchYiCd98THU/Y+whX8Qg
# UWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn15GkvmB0t9dmpsh3lGwIDAQABo4IB
# OjCCATYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU7NfjgtJxXWRM3y5nP+e6
# mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDgYDVR0PAQH/
# BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29jc3Au
# ZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2Vy
# dC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MEUGA1UdHwQ+MDwwOqA4
# oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJv
# b3RDQS5jcmwwEQYDVR0gBAowCDAGBgRVHSAAMA0GCSqGSIb3DQEBDAUAA4IBAQBw
# oL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyhhyzshV6pGrsi+IcaaVQi7aSId229GhT0
# E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO0Cre+i1Wz/n096wwepqLsl7Uz9FDRJtD
# IeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo8L8vC6bp8jQ87PcDx4eo0kxAGTVGamlU
# sLihVo7spNU96LHc/RzY9HdaXFSMb++hUD38dglohJ9vytsgjTVgHAIDyyCwrFig
# DkBjxZgiwbJZ9VVrzyerbHbObyMt9H5xaiNrIv8SuFQtJ37YOtnwtoeW/VvRXKwY
# w02fc7cBqZ9Xql4o4rmUMIIF9TCCA92gAwIBAgIQHaJIMG+bJhjQguCWfTPTajAN
# BgkqhkiG9w0BAQwFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJz
# ZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNU
# IE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBB
# dXRob3JpdHkwHhcNMTgxMTAyMDAwMDAwWhcNMzAxMjMxMjM1OTU5WjB8MQswCQYD
# VQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdT
# YWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJDAiBgNVBAMTG1NlY3Rp
# Z28gUlNBIENvZGUgU2lnbmluZyBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
# AQoCggEBAIYijTKFehifSfCWL2MIHi3cfJ8Uz+MmtiVmKUCGVEZ0MWLFEO2yhyem
# mcuVMMBW9aR1xqkOUGKlUZEQauBLYq798PgYrKf/7i4zIPoMGYmobHutAMNhodxp
# ZW0fbieW15dRhqb0J+V8aouVHltg1X7XFpKcAC9o95ftanK+ODtj3o+/bkxBXRIg
# CFnoOc2P0tbPBrRXBbZOoT5Xax+YvMRi1hsLjcdmG0qfnYHEckC14l/vC0X/o84X
# pi1VsLewvFRqnbyNVlPG8Lp5UEks9wO5/i9lNfIi6iwHr0bZ+UYc3Ix8cSjz/qfG
# FN1VkW6KEQ3fBiSVfQ+noXw62oY1YdMCAwEAAaOCAWQwggFgMB8GA1UdIwQYMBaA
# FFN5v1qqK0rPVIDh2JvAnfKyA2bLMB0GA1UdDgQWBBQO4TqoUzox1Yq+wbutZxoD
# ha00DjAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHSUE
# FjAUBggrBgEFBQcDAwYIKwYBBQUHAwgwEQYDVR0gBAowCDAGBgRVHSAAMFAGA1Ud
# HwRJMEcwRaBDoEGGP2h0dHA6Ly9jcmwudXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RS
# U0FDZXJ0aWZpY2F0aW9uQXV0aG9yaXR5LmNybDB2BggrBgEFBQcBAQRqMGgwPwYI
# KwYBBQUHMAKGM2h0dHA6Ly9jcnQudXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RSU0FB
# ZGRUcnVzdENBLmNydDAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNlcnRydXN0
# LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEATWNQ7Uc0SmGk295qKoyb8QAAHh1iezrX
# MsL2s+Bjs/thAIiaG20QBwRPvrjqiXgi6w9G7PNGXkBGiRL0C3danCpBOvzW9Ovn
# 9xWVM8Ohgyi33i/klPeFM4MtSkBIv5rCT0qxjyT0s4E307dksKYjalloUkJf/wTr
# 4XRleQj1qZPea3FAmZa6ePG5yOLDCBaxq2NayBWAbXReSnV+pbjDbLXP30p5h1zH
# QE1jNfYw08+1Cg4LBH+gS667o6XQhACTPlNdNKUANWlsvp8gJRANGftQkGG+OY96
# jk32nw4e/gdREmaDJhlIlc5KycF/8zoFm/lv34h/wCOe0h5DekUxwZxNqfBZslkZ
# 6GqNKQQCd3xLS81wvjqyVVp4Pry7bwMQJXcVNIr5NsxDkuS6T/FikyglVyn7URnH
# oSVAaoRXxrKdsbwcCtp8Z359LukoTBh+xHsxQXGaSynsCz1XUNLK3f2eBVHlRHjd
# Ad6xdZgNVCT98E7j4viDvXK6yz067vBeF5Jobchh+abxKgoLpbn0nu6YMgWFnuv5
# gynTxix9vTp3Los3QqBqgu07SqqUEKThDfgXxbZaeTMYkuO1dfih6Y4KJR7kHvGf
# Wocj/5+kUZ77OYARzdu1xKeogG/lU9Tg46LC0lsa+jImLWpXcBw8pFguo/NbSwfc
# Mlnzh6cabVgwggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqGSIb3
# DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAX
# BgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0
# ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMxCzAJ
# BgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGln
# aUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0Ew
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXHJQPE
# 8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMfUBML
# JnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w1lbU
# 5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRktFLy
# dkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYbqMFk
# dECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yemj052FVUmcJgm
# f6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP65x9a
# bJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzKQtwY
# SH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo80Vg
# vCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjBJgj5
# FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXcheMBK9
# Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU7Nfj
# gtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsG
# AQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29jc3Au
# ZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdpY2Vy
# dC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDigNqA0
# hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0
# LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZIhvcN
# AQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd4ksp
# +3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiCqBa9
# qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl/Yy8
# ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeCRK6Z
# JxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYTgAnE
# tp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/a6fx
# ZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37xJV7
# 7QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmLNriT
# 1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0YgkP
# Cr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJRyvm
# fxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIGwDCC
# BKigAwIBAgIQDE1pckuU+jwqSj0pB4A9WjANBgkqhkiG9w0BAQsFADBjMQswCQYD
# VQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lD
# ZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4X
# DTIyMDkyMTAwMDAwMFoXDTMzMTEyMTIzNTk1OVowRjELMAkGA1UEBhMCVVMxETAP
# BgNVBAoTCERpZ2lDZXJ0MSQwIgYDVQQDExtEaWdpQ2VydCBUaW1lc3RhbXAgMjAy
# MiAtIDIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDP7KUmOsap8mu7
# jcENmtuh6BSFdDMaJqzQHFUeHjZtvJJVDGH0nQl3PRWWCC9rZKT9BoMW15GSOBwx
# Apb7crGXOlWvM+xhiummKNuQY1y9iVPgOi2Mh0KuJqTku3h4uXoW4VbGwLpkU7sq
# FudQSLuIaQyIxvG+4C99O7HKU41Agx7ny3JJKB5MgB6FVueF7fJhvKo6B332q27l
# Zt3iXPUv7Y3UTZWEaOOAy2p50dIQkUYp6z4m8rSMzUy5Zsi7qlA4DeWMlF0ZWr/1
# e0BubxaompyVR4aFeT4MXmaMGgokvpyq0py2909ueMQoP6McD1AGN7oI2TWmtR7a
# eFgdOej4TJEQln5N4d3CraV++C0bH+wrRhijGfY59/XBT3EuiQMRoku7mL/6T+R7
# Nu8GRORV/zbq5Xwx5/PCUsTmFntafqUlc9vAapkhLWPlWfVNL5AfJ7fSqxTlOGaH
# UQhr+1NDOdBk+lbP4PQK5hRtZHi7mP2Uw3Mh8y/CLiDXgazT8QfU4b3ZXUtuMZQp
# i+ZBpGWUwFjl5S4pkKa3YWT62SBsGFFguqaBDwklU/G/O+mrBw5qBzliGcnWhX8T
# 2Y15z2LF7OF7ucxnEweawXjtxojIsG4yeccLWYONxu71LHx7jstkifGxxLjnU15f
# VdJ9GSlZA076XepFcxyEftfO4tQ6dwIDAQABo4IBizCCAYcwDgYDVR0PAQH/BAQD
# AgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwIAYDVR0g
# BBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMB8GA1UdIwQYMBaAFLoW2W1NhS9z
# KXaaL3WMaiCPnshvMB0GA1UdDgQWBBRiit7QYfyPMRTtlwvNPSqUFN9SnDBaBgNV
# HR8EUzBRME+gTaBLhklodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRU
# cnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3JsMIGQBggrBgEF
# BQcBAQSBgzCBgDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29t
# MFgGCCsGAQUFBzAChkxodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3J0MA0GCSqG
# SIb3DQEBCwUAA4ICAQBVqioa80bzeFc3MPx140/WhSPx/PmVOZsl5vdyipjDd9Rk
# /BX7NsJJUSx4iGNVCUY5APxp1MqbKfujP8DJAJsTHbCYidx48s18hc1Tna9i4mFm
# oxQqRYdKmEIrUPwbtZ4IMAn65C3XCYl5+QnmiM59G7hqopvBU2AJ6KO4ndetHxy4
# 7JhB8PYOgPvk/9+dEKfrALpfSo8aOlK06r8JSRU1NlmaD1TSsht/fl4JrXZUinRt
# ytIFZyt26/+YsiaVOBmIRBTlClmia+ciPkQh0j8cwJvtfEiy2JIMkU88ZpSvXQJT
# 657inuTTH4YBZJwAwuladHUNPeF5iL8cAZfJGSOA1zZaX5YWsWMMxkZAO85dNdRZ
# PkOaGK7DycvD+5sTX2q1x+DzBcNZ3ydiK95ByVO5/zQQZ/YmMph7/lxClIGUgp2s
# CovGSxVK05iQRWAzgOAj3vgDpPZFR+XOuANCR+hBNnF3rf2i6Jd0Ti7aHh2MWsge
# mtXC8MYiqE+bvdgcmlHEL5r2X6cnl7qWLoVXwGDneFZ/au/ClZpLEQLIgpzJGgV8
# unG1TnqZbPTontRamMifv427GFxD9dAq6OJi7ngE273R+1sKqHB+8JeEeOMIA11H
# LGOoJTiXAdI/Otrl5fbmm9x+LMz/F0xNAKLY1gEOuIvu5uByVYksJxlh9ncBjDGC
# BWcwggVjAgEBMIGQMHwxCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1h
# bmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoTD1NlY3RpZ28gTGlt
# aXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBTaWduaW5nIENBAhA+ii5i
# HolIoJc0Gy3BlHV8MA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAI
# oAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIB
# CzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIMFibUosaZynnpY3xFMN
# 4JIHZ+KS2zhp3b/zfIUa1EdQMA0GCSqGSIb3DQEBAQUABIIBAKjKPgtu+UW2ElZv
# 5p8RfV5LYj69evgzge405pps5LqREXGEUhFjFDtq1q1/X4pybs5pbqeXtvK0Zv4J
# E0vcS3rZSPI0AIvAA5W9fWlZ/A13qFvXqJE7ODYyBLlkVULYh1hI0zy1vy1qPrnL
# zOL+sG9h5uTaEVgATnbRcmLFMFZkGWHiXb3+tLg+K1aExsxkwD5pGKDsMXY0K3mb
# c+7KCFNXpP6gExK5+suRGmcrcb71dR0x2/XWkHfD/xzZCZEKcgyR4EN81TzHfiaz
# Q7bg9EpfIXgvf9u6LbpmHZituQp9kdbrXsyJhQXCnt9M25AJH5KfUxXVnkBdOKqP
# om5UD+OhggMgMIIDHAYJKoZIhvcNAQkGMYIDDTCCAwkCAQEwdzBjMQswCQYDVQQG
# EwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0
# IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBAhAMTWly
# S5T6PCpKPSkHgD1aMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqG
# SIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjIxMTAyMTUzMDI0WjAvBgkqhkiG9w0B
# CQQxIgQggj8xY9fpyWIoLdO/BGJGqTZDOa/HPTnZ9kih/kSYa+gwDQYJKoZIhvcN
# AQEBBQAEggIAu/Juv9WVQZ4Pgn6FBpRccjwPPBlBwu8YM8/57D1wNhqjWfVOT32B
# zAcCE/YgwqTZmGxqJTMSxUoqMdmZgrFrh5t+fBKJDljdVpkbhZpAC8+imzNY/3v9
# ChSjyWINjvsQefWdu0wNTXQt5WjFZZa7T9JGMRl7ljqJWSqimJrFysK4mwGYkuw7
# Gv4CwoGi6xR1g1VfqyL5w8HGsh/kM/nZagarj55k/sZL1o+Fp9lNaAfoaRRUSxuL
# AK6SdJVCbUVBQ7MQyaO74eFb2epPUt1OOrlEC0NPWckxXkQek2api13vpT2/J/Kz
# w7NdnxLMHDaOgU9vHDNnFTswuFzXtgfeNHgtq5x0gIc7YNLfIAkxGle3CzuTBaaF
# 9JPGtRIxY2wX2dtWsairuR3sZbtI/VFSW/sau0fFiauaFwE3FathfuNsSSg5dG0k
# RhRdJmkC20w7w6NooUIhjJ0+7kSJ9/G+hF7O4hgnR2y/HDp4Ddu59qlA7k/Gc2x9
# Wb0/C+gdU21hruhqMP8+tHiuBsclWLIX4M1hQqeJYciYbwJf98G29Q1FJk4Ya6Te
# nuaMcsnElVdlaDIYrYfxoOwSnt3kikSxoghn/mdGdUaNqg6mKV14UQDBMxI+l1I/
# WoVlQ8ThIRq9cqfGPwq2r9OWkoFRITZo2QPfGFZysCm4fMKlyOIIixU=
# SIG # End signature block
