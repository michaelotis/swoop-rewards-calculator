#Update to your rewards pair (one_busd, link_1eth, 1eth_1btc)
$pair = "one_busd" 

#Update to your $ONE address
$address = "one..." 

#Change to increase or decrease loop time to calculate, longer the more accurate estimates will be
$loopInMinutes = 10

$obj = @{jsonrcp = "2.0";id=1;method="hmyv2_blockNumber";params=@()} | ConvertTo-Json
$endingblock = 5914349
$startingbalance=(((Invoke-RestMethod http://rewards.swoop.exchange/$pair).Split("`n").Trim() |Where {$_ -like "*$address*"}).Split(" ") |Where {$_})[1]
while($blocknumber -lt $endingblock){
Clear
$blocknumber = (Invoke-RestMethod https://rpc.s0.t.hmny.io -Method POST -ContentType 'application/json' -Body $obj).result
$timeleft= ((get-date).AddSeconds(($endingblock-$blocknumber)*5) - (Get-Date))
$balance = (((Invoke-RestMethod http://rewards.swoop.exchange/$pair).Split("`n").Trim() |Where {$_ -like "*$address*"}).Split(" ") |Where {$_})[1]
$output = [pscustomobject]@{
    Blocknumber=$blocknumber
    RemainingBlocks=($endingblock-$blocknumber)
    Balance="`$$balance"
    'Estimated Ending Balance' = "`$$([math]::Round(($balance-$startingbalance)*($timeleft.TotalMinutes/$loopInMinutes) + $balance, 2))"
    TimeLeft= "$($timeleft.Days) Days, $($timeleft.Hours) Hours, $($timeleft.Minutes) Minutes"
    NextRun=(Get-Date).AddMinutes($loopInMinutes)
}
$startingbalance = $balance
$output
Write-Host "Sleeping $loopInMinutes Minutes..."
Sleep (60*$loopInMinutes)
}
