function Navigate{
	Param(
		[Parameter(Position=0,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[string]$searchURL,
		[Parameter(Position=1,
		Mandatory=$False,
		ValueFromPipeline=$False)]
	  [string]$viewContent
	)

	
	if (IsSearchObject $searchURL){
		$navigationURL = RemoveIndex $searchURL
	}
	else {
		$navigationURL = $searchURL
	}
	$page = (Invoke-WebRequest $navigationURL)

	switch ($viewContent){
		"" {DisplayBodyInnerText $page}
		"links" {DisplayLinks $page}
		"page" {DisplayBodyInnerText $page}
	}	
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
		[array]$page
	)

	$pageP = foreach ($element in $page.ParsedHtml.body.getElementsByTagName("p"))
		{
			$element.innerText
		}

	foreach ($para in $pageP){
		$para + "`n"
	}
}


# Display links of URL
function DisplayLinks{
	Param(
		[Parameter(Position=0,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[array]$page
	)

	$links = $page.Links.href

	$links
}


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