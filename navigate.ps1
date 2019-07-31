function Navigate{
	Param(
		[Parameter(Position=0,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[string]$searchURL
	)

	$navigationURL = RemoveIndex $searchURL
	DisplayBodyInnerText $navigationURL
	
	if (IsSearchObject $searchURL){
		$navigationURL = RemoveIndex $searchURL
	}
	else {
		$navigationURL = $searchURL
	}
	$page = (Invoke-WebRequest $navigationURL)
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
# Return true/false if provided URL for navigate() is/n't an object from search() array collection
function IsSearchObject{
	Param(
		[Parameter(Position=0,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[string]$navigationURL
	)
	if ($navigationURL[0] -eq "["){
		return $true
	}

	return $false
}