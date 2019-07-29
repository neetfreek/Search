function Navigate{
	Param(
		[Parameter(Position=0,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[string]$searchURL
	)

	$navigationURL = RemoveIndex $searchURL
	DisplayBodyInnerText $navigationURL
}

# Remove URL's index position in result collection for navigation
function RemoveIndex(){
	Param(
		[Parameter(Position=0,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[string]$searchURL
	)

	$splitURL = $searchURL -Split "]"
	return $splitURL[1]
}

# Display body of URL
function DisplayBodyInnerText{
	Param(
		[Parameter(Position=0,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[string]$searchURL
	)
	(Invoke-WebRequest $searchURL).ParsedHTML.body.innerText
}