function Get-SP500Summary {
    [CmdletBinding()]
    $response = invoke-webrequest "https://www.slickcharts.com/sp500"
    $table = $response.parsedhtml.body.childnodes[6].childnodes[1].childnodes[0].childnodes[0].childnodes[1].childnodes[0]
    # Column Headers
    $columns = foreach ($node in $table.childnodes[0].childnodes[0].childnodes) {$node.innertext.trim()}

    $stockrows = $table.childnodes[1].childnodes
    $stocks = foreach ($row in $stockrows) {
        $attributes = @{}
        for ($i=0; $i -lt $($columns.count); $i++) {
            $attributes.Add($columns[$i],$row.childnodes[$i].innertext.trim())
        }
        [PSCustomObject]$attributes
    }

    $stocks
}

$stocks = Get-SP500Summary

function Get-SharesInAmount {
	[CmdletBinding()]
	param (
		$stock,
		$amount,
		$transactionCost = 5,
		$maxCostRatio = 0.02
	)
	
	begin {
	}
	
	process {
		$sharesToConsider = [Math]::floor(($amount * ($stock.Weight)/100) / ($stock.Price) )
		$purchasePrice = ($sharesToConsider * $stock.Price) + $transactionCost
		if ($transactionCost/$purchasePrice -gt $maxCostRatio) {
			$sharesToConsider = 0
			$purchasePrice = 0
		}
		[PSCustomObject]@{
			Symbol = $stock.Symbol
			Company = $stock.Company
			Shares = $sharesToConsider
			Cost = $purchasePrice
		}
	}
	
	end {
	}
}

function Get-RawPortfolio {
	[CmdletBinding()]
	param (
		$amount,
		$transactionCost = 5,
		$maxCostRatio = 0.02
	)
	
	begin {
		
	}
	
	process {
		if ($null -eq $stocks) {
			$stocks = Get-SP500Summary
        }
        $purchases = @()
		foreach ($stock in $stocks) {
			$purchase = Get-SharesInAmount -stock $stock -amount $amount -transactionCost $transactionCost -maxCostRatio $maxCostRatio
			if ($purchase.Shares -gt 0) {
				$purchases += $purchase
			}
		}
	}
	
	end {
        [PSCustomObject]@{
            'portfolio' = $purchases
            'cost' = CostOfPurchases($purchases)
        }
	}
}

function CostOfPurchases {
    param(
        $purchases
    )
    $cost = 0
    foreach ($stock in $purchases) {
        $cost += $stock.Cost
    }
    $cost
}

function Get-PercentageFit {
    [CmdletBinding()]
    param(
        $initialAmount,
        $transactionCost = 5,
		$maxCostRatio = 0.02
    )
    $rawPortfolio = Get-RawPortfolio -amount $initialAmount -transactionCost $transactionCost -maxCostRatio $maxCostRatio
    $costOfRawPortfolio = $rawPortfolio.cost
    $percentageFit = $costOfRawPortfolio/$initialAmount
    $percentageFit
}

function Get-BestFitPortfolio {
    [CmdletBinding()]
    param(
        $amount,
        $transactionCost = 5,
		$maxCostRatio = 0.02
    )
	$currentAmount = $amount
	do {
		$currentAmount += 10000
	} while((Get-RawPortfolio -amount $currentAmount -transactionCost $transactionCost -maxCostRatio $maxCostRatio).cost -lt $amount )
	$currentAmount = $currentAmount - 10000
	do {
		$currentAmount += 1000
	} while((Get-RawPortfolio -amount $currentAmount -transactionCost $transactionCost -maxCostRatio $maxCostRatio).cost -lt $amount )
	$currentAmount = $currentAmount - 1000
	do {
		$currentAmount += 100
	} while((Get-RawPortfolio -amount $currentAmount -transactionCost $transactionCost -maxCostRatio $maxCostRatio).cost -lt $amount )
	$currentAmount = $currentAmount - 100
	do {
		$currentAmount += 10
	} while((Get-RawPortfolio -amount $currentAmount -transactionCost $transactionCost -maxCostRatio $maxCostRatio).cost -lt $amount )
	$currentAmount = $currentAmount - 10
	do {
		$currentAmount += 1
	} while((Get-RawPortfolio -amount $currentAmount -transactionCost $transactionCost -maxCostRatio $maxCostRatio).cost -lt $amount )
	$portfolio = Get-RawPortfolio -amount ($currentAmount - 1) -transactionCost $transactionCost -maxCostRatio $maxCostRatio
	$portfolio
}