<#
    .SYNOPSIS
        Inventory-SPFarm wil inventory (nearly) all items in a SharePoint 2007, 2010, 2013 farm using the SP object model.
    .DESCRIPTION
        This script is a collection of functions that will inventory a SharePoint 2007, SharePoint 2010, or SharePoint 2013 content.  
        The output is a collection of csv files that can then be ported to Excel, PowerPivot, Access, SQL Server, etc. for futher analysis.  
        If you so desire, you can selectively inventory subsets of data.  See EXAMPLES for usage.
        No support or warranty is supplied or inferred.
  	.PARAMETER InventoryFarmSolutions
        Gather information about farm solutions
	.PARAMETER InventoryFarmFeatures
        Gather information about farm features
	.PARAMETER InventoryWebTemplates
        Gather information about web templates
    .PARAMETER InventoryWebApplications
        Gather information about web
	.PARAMETER InventoryContentDatabases
        Gather information about content databases 
	.PARAMETER InventorySiteCollections
        Gather information about site collections
	.PARAMETER InventorySiteCollectionAdmins
        Gather information about site collection admins
	.PARAMETER InventorySiteCollectionFeatures
        Gather information about site collection features
	.PARAMETER InventoryWebPermissions
        Gather information about site permissions
	.PARAMETER InventoryWebs
        Gather information about sites
	.PARAMETER InventoryWebWorkflowAssociations
        Gather information about workflows and their associations
	.PARAMETER InventorySiteContentTypes
        Gather information about site content types
	.PARAMETER InventoryWebSize
        Gather information about site sizes
	.PARAMETER InventoryWebFeatures
        Gather information about site features
	.PARAMETER InventoryLists
        Gather information about lists and libraries
	.PARAMETER InventoryListWorkflowAssociations
        Gather information about workflows associated to lists
	.PARAMETER InventoryListFields
        Gather information about list fields
	.PARAMETER InventoryListViews
        Gather information about list views
	.PARAMETER InventoryListContentTypes 
        Gather information about list content types
	.PARAMETER InventoryWebParts
        Gather information about web parts
	.PARAMETER InventoryContentTypeWorkflowAssociations
        Gather information about workflows associated to content types
	.PARAMETER LogFilePrefix
        Prefix for each output file (required)
	.PARAMETER DestinationFolder
        Path to folder in which output files will be created (required)

    .INPUTS
        See parameters.
    .OUTPUTS
        A collection of CSV files (one for each class of SP object) containing object properties/metadata.
	.AUTHOR
		James Hammonds, @jameswh3
        Jeff Border, @jeffbor
		The web part inventory section is mostly borrowed from Joe Rodgers.
	.getStarted
		To run the full inventory, load this script in PowerShell, then enter: Run-FullInventory -DestinationFolder "e:\temp" -LogFilePrefix "YourFarm_"
		Just make sure that the destination folder (and drive) has enough space for the log files (gigs in some cases), and that your LogFilePrefix is appropriate
    .EXAMPLE
        Inventory everything:
        Run-FullInventory -DestinationFolder "e:\ProdFarmInventory" -LogFilePrefix "Prod_"
    .EXAMPLE:
        Inventory only farm solutions and farm features
        Inventory-SPFarm -InventoryFarmSolutions -InventoryFarmFeatures -DestinationFolder "e:\ProdFarmInventory" -LogFilePrefix "Prod_"
	.NOTES
		When running against SharePoint 2007 and in older versions of PowerShell, ensure you set the PS Session version to 2.0.
        Although this script disposes of objects when applicable, it can adversely affect the performance and memory usage of some farm servers.
#>

function Inventory-SPFarm {
	[cmdletbinding()]
	param (
		[switch]$InventoryFarmSolutions,
		[switch]$InventoryFarmFeatures,
		[switch]$InventoryWebTemplates,
        [switch]$InventoryWebApplications,
		[switch]$InventoryContentDatabases,
		[switch]$InventorySiteCollections,
		[switch]$InventorySiteCollectionAdmins,
		[switch]$InventorySiteCollectionFeatures,
		[switch]$InventoryWebPermissions,
		[switch]$InventoryWebs,
		[switch]$InventoryWebWorkflowAssociations,
		[switch]$InventorySiteContentTypes,
		[switch]$InventoryWebSize,
		[switch]$InventoryWebFeatures,
		[switch]$InventoryLists,
		[switch]$InventoryListWorkflowAssociations,
		[switch]$InventoryListFields,
		[switch]$InventoryListViews,
		[switch]$InventoryListContentTypes,
		[switch]$InventoryWebParts,
		[switch]$InventoryContentTypeWorkflowAssociations,
		[switch]$InventoryAlternateAccessMappings,
		[switch]$InventoryFarmProperties,
		[Parameter(Mandatory=$true)][string]$LogFilePrefix,
		[Parameter(Mandatory=$true)][string]$DestinationFolder
	)
	BEGIN {
		[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
		$ContentService = [Microsoft.SharePoint.Administration.SPWebService]::ContentService;
		$getContentDBName = [Microsoft.SharePoint.Administration.SPContentDatabase].GetMethod("get_Name")
		$getContentDBServerName = [Microsoft.SharePoint.Administration.SPContentDatabase].GetMethod("get_Server") 
		$farm = [Microsoft.SharePoint.Administration.SPFarm]::Local
		Write-Host "Inventorying farm $($farm.Name)..." -ForegroundColor DarkGray
	} #BEGIN
	Process {
		if ($InventoryFarmFeatures) {
			Inventory-SPFarmFeatures -farm $farm -logfilename ($DestinationFolder + "\" + $LogFilePrefix + "FarmFeatures.csv")
		} #if inventoryfarmfeatures
		if ($InventoryFarmSolutions) {
			#Inventory Farm Solutions
			Inventory-SPFarmSolutions -farm $farm -logfilename ($DestinationFolder + "\" + $LogFilePrefix + "FarmSolutions.csv")
		} #if inventoryfarmsolutions
		if ($InventoryWebTemplates) {
			Inventory-SPWebTemplates -FarmVersion $farm.buildversion.major -lcid "1033" -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder
		} #if InventoryWebTemplates
		if ($InventoryAlternateAccessMappings) {
			Inventory-AlternateAccessMappings -farm $farm -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder
		} #if inventoryfarmfeatures
		if ($InventoryFarmProperties) {
			Inventory-FarmProperties -farm $farm -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder
		} #if inventoryfarmfeatures
		if (
				$InventoryWebApplications -or 
				$InventorySiteCollections -or 
				$InventorySiteCollectionAdmins -or
				$InventorySiteCollectionFeatures -or 
				$InventoryWebFeatures -or 
				$InventoryWebPermissions -or 
				$InventoryWebs -or 
				$InventoryWebWorkflowAssociations -or 
				$InventorySiteContentTypes -or
				$InventoryLists -or 
				$InventoryListWorkflowAssociations -or
				$InventoryListContentTypes -or
				$InventoryContentTypeWorkflowAssociations -or
				$InventoryListFields -or 
				$InventoryListViews -or 
				$InventoryWebParts
			) { 
			Inventory-SPWebApplications `
                -ContentService $ContentService `
                -LogFilePrefix $LogFilePrefix `
                -DestinationFolder $DestinationFolder `
                -InventorySiteCollections:$InventorySiteCollections `
                -InventorySiteCollectionAdmins:$InventorySiteCollectionAdmins `
                -InventorySiteCollectionFeatures:$InventorySiteCollectionFeatures `
                -InventoryWebPermissions:$InventoryWebPermissions `
                -InventoryWebs:$InventoryWebs `
				-InventoryWebWorkflowAssociations:$InventoryWebWorkflowAssociations `
				-InventorySiteContentTypes:$InventorySiteContentTypes `
                -InventoryLists:$InventoryLists `
				-InventoryListWorkflowAssociations:$InventoryListWorkflowAssociations `
				-InventoryListContentTypes:$InventoryListContentTypes `
				-InventoryContentTypeWorkflowAssociations:$InventoryContentTypeWorkflowAssociations `
                -InventoryListFields:$InventoryListFields `
                -InventoryListViews:$InventoryListViews `
                -InventoryWebParts:$InventoryWebParts `
                -InventoryWebFeatures:$InventoryWebFeatures `
                -InventoryWebSize:$InventoryWebSize
		} #if inventorywebapplications or child items
	}#PROCESS
	End {
        Write-Host "Inventory of farm $($farm.Name) complete." -ForegroundColor DarkGray
    } #END
}

function Inventory-SPFarmSolutions {
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]$farm,
		[Parameter(Mandatory=$true)]$logfilename
	) #param
	BEGIN {
		$Area = "FarmSolution"
		$now = Get-Date
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name)..." -ForegroundColor DarkCyan
		$solutions = $farm.Solutions
		if (-not (test-path $logfilename)) {
			$row = '"SoulutionId","SolutionDisplayName"' 
			$row | Out-File $logfilename
		}
	} #BEGIN
	PROCESS {
		$counter = 0
		foreach ($solution in $solutions) { 
				$row='"'+$solution.ID+'","'+$solution.DisplayName+'"'
				$row | Out-File $logfilename -append 
				$counter++
			} #foreach solution
	} #PROCESS
	END {
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name) complete.  $counter $Area(s) inventoried." -ForegroundColor DarkCyan
	} #END
}

function Inventory-SPFarmFeatures {
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]$farm,
		[Parameter(Mandatory=$true)]$logfilename
	) #param
	BEGIN {
        $now=get-date
		$Area = "FarmFeature"
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name)..." -ForegroundColor DarkCyan
		$featuredefs = $farm.FeatureDefinitions
		if (-not (test-path $logfilename)) {
			$row = '"FeatureId","FeatureDisplayName","FeatureScope","FeatureTypeName","SolutionId","FeatureTitle","ScriptRunDate"'
			$row | Out-File $logfilename
		}
	} #BEGIN
	PROCESS {
		$counter = 0
		foreach ($featuredef in $featuredefs) {
				#TODO***********************************************resolve TypeName to something more descriptive
				$row='"'+$featuredef.ID+'","'+$featuredef.DisplayName+'","'+$featuredef.Scope+'","'+$featuredef.TypeName+'","'+$featuredef.SolutionId+'","'+$featuredef.Title+'","'+$now+'"'
				$row | Out-File  $logfilename -append 
				$counter++
			}  #foreach featuredef
	} #PROCESS
	END {
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name) complete.  $counter $Area(s) inventoried." -ForegroundColor DarkCyan 
	} #END
}

function Inventory-SPWebTemplates {
	param (
		$FarmVersion="12",
		$lcid="1033",
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder
	) #param
	BEGIN {
		$Area="WebTemplate"
        $now=get-date
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name)..." -ForegroundColor DarkCyan 
		
		# Rewrite following to survive non-standard configurations
		$templateFiles=get-childitem "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\$farmVersion\TEMPLATE\$lcid\XML" -filter "webtemp*.xml"

		$logfilename=($DestinationFolder + "\" + $LogFilePrefix + "WebTemplates.csv")
		if (-not (test-path $logfilename)) {
			$row = '"TemplateName","TemplateID","TemplateFileName"' 
			$row | Out-File $logfilename -append
		}
	} #begin
	PROCESS {
		$counter = 0
		foreach ($tf in $templateFiles) {
			$fileName=$tf.Name
            write-host "    Processing $Area file $($tf.Name)..." -ForegroundColor DarkYellow
			[xml]$xml=(get-content $tf.fullname)
			$templates=$xml.Templates.template
			foreach ($t in $templates) {
				write-host "      $($t.Name)" -ForegroundColor DarkYellow
				$row=''
				$row='"'+$t.Name+'","'+$t.id+'","'+$fileName+'"'
				$row | Out-File $logfilename -append
				$counter++
			}
		}
	} #process
	END {
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name) complete.  $counter $Area(s) inventoried." -ForegroundColor DarkCyan 
	} #end
}

function Inventory-SPWebApplications  {
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]$ContentService,
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder,
		[switch]$InventoryWebSize,
		[switch]$InventorySiteCollections,
		[switch]$InventorySiteCollectionAdmins,
		[switch]$InventorySiteCollectionFeatures,
		[switch]$InventoryWebFeatures,
		[switch]$InventoryWebPermissions,
		[switch]$InventoryWebs,
		[switch]$InventoryWebWorkflowAssociations,
		[switch]$InventorySiteContentTypes,
		[switch]$InventoryListContentTypes,
		[switch]$InventoryContentTypeWorkflowAssociations,
		[switch]$InventoryLists,
		[switch]$InventoryListWorkflowAssociations,
		[switch]$InventoryListFields,
		[switch]$InventoryListViews,
		[switch]$InventoryWebParts
	) #param
	BEGIN { 
		$Area="WebApp"
        $now=get-date
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name)..." -ForegroundColor DarkCyan 
		[Microsoft.SharePoint.Administration.SPWebApplicationCollection]$waColl = $ContentService.WebApplications;
		$webApps=$waColl | where-object {$_.IsAdministrationWebApplication -eq $FALSE}
		#set up logfile
        $logfilename=($DestinationFolder + "\" + $LogFilePrefix + "WebApplications.csv")
		if (-not (test-path $logfilename)) {
			$row = '"WebAppUrl","WebAppName","Farm","ScriptRunDate"'
			$row | Out-File $logfilename
		}
	} #BEGIN
	PROCESS {
		$counter = 0
		foreach ($wa in $webApps) {
			try {
				Write-Host "    Inventorying $Area $($wa.alternateurls[0].IncomingUrl)..." -ForegroundColor DarkYellow
				$Location=$wa.Url
                #$wa | get-member | out-gridview
				$row = '"'+$wa.alternateurls[0].IncomingUrl+'","'+$wa.Name+'","'+$($wa.farm.Name)+'","'+$now+'"'
				$row | Out-File $logfilename -append
				if (
						$InventorySiteCollections -or 
						$InventorySiteCollectionAdmins -or
						$InventorySiteCollectionFeatures -or 
						$InventoryWebFeatures -or 
						$InventoryWebPermissions -or 
						$InventoryWebs -or 
						$InventoryWebWorkflowAssociations -or 
						$InventorySiteContentTypes -or
						$InventoryLists -or 
						$InventoryListWorkflowAssociations -or 
						$InventoryListContentTypes -or
						$InventoryContentTypeWorkflowAssociations -or
						$InventoryListFields -or 
						$InventoryListViews -or 
						$InventoryWebParts
					) { 
					Inventory-SPSiteCollections `
                        -WebApp $wa `
                        -LogFilePrefix $LogFilePrefix `
                        -DestinationFolder $DestinationFolder `
                        -InventorySiteCollectionAdmins:$InventorySiteCollectionAdmins `
                        -InventorySiteCollectionFeatures:$InventorySiteCollectionFeatures `
                        -InventoryWebPermissions:$InventoryWebPermissions `
                        -InventoryWebs:$InventoryWebs `
						-InventoryWebWorkflowAssociations:$InventoryWebWorkflowAssociations `
						-InventorySiteContentTypes:$InventorySiteContentTypes `
                        -InventoryWebFeatures:$InventoryWebFeatures `
                        -InventoryLists:$InventoryLists `
						-InventoryListWorkflowAssociations:$InventoryListWorkflowAssociations `
						-InventoryListContentTypes:$InventoryListContentTypes `
						-InventoryContentTypeWorkflowAssociations:$InventoryContentTypeWorkflowAssociations `
                        -InventoryListFields:$InventoryListFields `
                        -InventoryListViews:$InventoryListViews `
                        -InventoryWebParts:$InventoryWebParts  `
                        -InventoryWebSize:$InventoryWebSize
				}
				$counter++
			} #try
			catch {
				Record-Error $Location $Area $error[0] $LogFilePrefix $DestinationFolder
			} #catch
		} #foreach webapp
	} #PROCESS
	END{
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name) complete.  $counter $Area(s) inventoried." -ForegroundColor DarkCyan 
	} #END
}

function Inventory-SPSiteCollections {
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]$WebApp,
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder,
		[switch]$InventoryWebSize,
		[switch]$InventorySiteCollectionAdmins,
		[switch]$InventorySiteCollectionFeatures,
		[switch]$InventoryWebFeatures,
		[switch]$InventoryWebPermissions,
		[switch]$InventoryWebs,
		[switch]$InventoryWebWorkflowAssociations,
		[switch]$InventorySiteContentTypes,
		[switch]$InventoryContentTypeWorkflowAssociations,
		[switch]$InventoryLists,
		[switch]$InventoryListWorkflowAssociations,
		[switch]$InventoryListContentTypes,
		[switch]$InventoryListFields,
		[switch]$InventoryListViews,
		[switch]$InventoryWebParts
	) #param
	BEGIN { 
		$Area="Site Collection"
        $now=get-date
		$getContentDBName = [Microsoft.SharePoint.Administration.SPContentDatabase].getmethod("get_Name")
		$getContentDBServerName = [Microsoft.SharePoint.Administration.SPContentDatabase].getmethod("get_Server")
		#set up log file
		$logfilename=($DestinationFolder + "\" + $LogFilePrefix + "SiteCollections.csv")
		if (-not (test-path $logfilename)) {
			$row = '"Site","ContentDB","ContentDbServer","ScriptRunDate","LastSiteContentModified","SiteGUID","Storage","Visits"'
			$row | Out-File $logfilename
		}
		$sites=$wa.Sites
		Write-Host "  Inventorying $Area in $($wa.alternateurls[0].IncomingUrl)..." -ForegroundColor DarkCyan
	} #begin
	PROCESS {
		$counter = 0
		foreach ($site in $sites) {
			$Location=$site.Url
			try {
				Write-Host "        Inventorying $Area $($site.url)..." -ForegroundColor DarkCyan
				$contentDb='' 
				$contentDb = $getContentDBName.Invoke($site.ContentDatabase,"instance,public", $null, $null, $null)
				$contentDbServer = $getContentDBServerName.Invoke($site.ContentDatabase,"instance,public", $null, $null, $null)
				$row='' 
				$row='"'+$site.Url+'","'+$contentDb+'","'+$contentDbServer+'","'+$now+'","'+$site.LastContentModifiedDate+'","'+$site.Id+'","'+$site.usage.storage+'","'+$site.usage.visits+'"'
				$row | Out-File $logfilename -append
				if ($InventorySiteCollectionAdmins) {
					Inventory-SPSiteCollectionAdmins -Site $site -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder
				} #if InventorySiteCollectionAdmins
				if ($InventorySiteCollectionFeatures) {
					Inventory-SPSiteCollectionFeatures -Site $site -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder
				} #if InventorySiteCollectionFeatures
				if (
					$InventoryWebs -or
					$InventoryWebFeatures -or 
					$InventoryWebPermissions -or 
					$InventoryWebs -or 
					$InventoryWebWorkflowAssociations -or
					$InventorySiteContentTypes -or 
					$InventoryLists -or 
					$InventoryListWorkflowAssociations -or 
					$InventoryListContentTypes -or
					$InventoryContentTypeWorkflowAssociations -or
					$InventoryListFields -or 
					$InventoryListViews -or 
					$InventoryWebParts
				) {
					Inventory-SPWebs `
                        -Site $site `
                        -LogFilePrefix $LogFilePrefix `
                        -DestinationFolder $DestinationFolder `
						-InventoryWebWorkflowAssociations:$InventoryWebWorkflowAssociations `
                        -InventoryWebPermissions:$InventoryWebPermissions `
                        -InventoryWebFeatures:$InventoryWebFeatures `
						-InventorySiteContentTypes:$InventorySiteContentTypes `
                        -InventoryLists:$InventoryLists `
						-InventoryListWorkflowAssociations:$InventoryListWorkflowAssociations `
						-InventoryListContentTypes:$InventoryListContentTypes `
						-InventoryContentTypeWorkflowAssociations:$InventoryContentTypeWorkflowAssociations `
                        -InventoryListFields:$InventoryListFields `
                        -InventoryListViews:$InventoryListViews `
                        -InventoryWebParts:$InventoryWebParts `
                        -InventoryWebSize:$InventoryWebSize
				} #if InventorySiteCollectionFeatures
				$counter++
			} #try
			catch {
				Record-Error $Location $Area $error[0] $LogFilePrefix $DestinationFolder
			} #catch
			finally {
				$site.Dispose()
			} #finally
		} #foreach site
	} #process
	END {
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name) complete.  $counter $Area(s) inventoried." -ForegroundColor DarkCyan 
	} #end
 }

function Inventory-SPSiteCollectionAdmins {
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]$site,
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder
	) #param
	BEGIN {
		$Area="Site Collection Admins"
		Write-Host "    Inventorying $Area in $($Site.url)..." -ForegroundColor DarkCyan
		$logfilename=($DestinationFolder + "\" + $LogFilePrefix + "SiteCollectionAdmins.csv")
		if (-not (test-path $logfilename)) {
			$row = '"Site","SiteAdmin","SiteID","ScriptRunDate"' 
			$row | Out-File $logfilename
		}
		$siteAdmins=$site.RootWeb.SiteAdministrators
	} #begin
	PROCESS {
		$counter = 0
		foreach ($siteAdmin in $siteAdmins) { 
			try {
				$Location=$site.Url
				$row='' 
				$row='"'+$site.Url+'","'+$siteAdmin.LoginName+'","'+$now+'"'
				$row | Out-File $logfilename -append
				$counter++
			}
			catch {
				Record-Error $Location $Area $error[0] $LogFilePrefix $DestinationFolder
			}
			finally {		
			}
		} #foreach site admin
	} #process
	END {
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name) complete. $counter $Area(s) inventoried." -ForegroundColor DarkCyan 
	} #end
 }
 
function Inventory-SPSiteCollectionFeatures {
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]$Site,
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder
	) #param
	BEGIN {
		$Area="Site Collection Features"
        $now=get-date
		Write-Host "  Inventorying $Area in $($Site.url)..." -ForegroundColor DarkCyan
		$logfilename=($DestinationFolder + "\" + $LogFilePrefix + "SiteCollectionFeatures.csv")
		if (-not (test-path $logfilename)) {
			$row = '"SiteCollection","WebUrl","ScriptRunDate","FeatureID","SearchedScope"'
			$row | Out-File $logfilename
		}
		$features=$site.Features
	} #begin
	PROCESS {
		$counter = 0
		foreach ($feature in $features) { 
			try {
				$Location=$site.Url
				$row='' 
				$row='"'+$site.Url+'","NA","'+$now+'","'+$feature.DefinitionId+'","Site"'
				$row | Out-File $logfilename -append
				$counter++
			}
			catch {
				Record-Error $Location $Area $error[0] $LogFilePrefix $DestinationFolder
			}
			finally {		
			}
		} #foreach site admin
	} #process
	END {
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name) complete. $counter $Area(s) inventoried." -ForegroundColor DarkCyan 
} #end
 }
  
function Inventory-SPWebs {
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]$Site,
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder,
		[switch]$InventoryWebWorkflowAssociations,
		[switch]$InventoryWebSize,
		[switch]$InventorySiteContentTypes,
		[switch]$InventoryWebPermissions,
		[switch]$InventoryWebFeatures,
		[switch]$InventoryLists,
		[switch]$InventoryListWorkflowAssociations,
		[switch]$InventoryListContentTypes,
		[switch]$InventoryContentTypeWorkflowAssociations,
		[switch]$InventoryListFields,
		[switch]$InventoryListViews,
		[switch]$InventoryWebParts
	) #param
	BEGIN {
		$Area="Web"
        $now=get-date
		Write-Host "  Inventorying $Area(s) in $Area $($Site.url)..." -ForegroundColor DarkCyan
		$logfilename=($DestinationFolder + "\" + $LogFilePrefix + "Webs.csv")
		if (-not (test-path $logfilename)) {
			$row = '"SiteCollection","WebTemplate","WebTemplateID","WebUrl","WebTheme","WebIsRoot","WebLastItemModifiedDate","ScriptRunDate","WebGUID","SiteGUID","ParentWebGUID","WebSize","UIVersion"'
			$row | Out-File $logfilename
		}
		$webs=$Site.AllWebs
	} #begin
	PROCESS {
		foreach ($web in $webs) {
			try {
				Write-Host "      Inventorying site $($web.url)..." -ForegroundColor DarkCyan
				$websize=$null
				$Location=$web.Url
				if ($InventoryWebSize) {
					$websize=(Get-SPWebSize -web $web -includesubwebs $false)/1MB
				} #if inventorywebsize
				$row='"'+$site.Url+'","'+$web.WebTemplate+'","'+$web.WebTemplateId+'","'+$web.Url+'","'+$web.Theme+'","'+$web.IsRootWeb+'","'+$web.LastItemModifiedDate+'","'+$now+'","'+$web.ID+'","'+$site.Id+'","'+$web.parentweb.id+'","'+$websize+'","'+$web.UIVersion+'"'
				$row | Out-File $logfilename -append
				if ($InventoryWebWorkflowAssociations) {
					Inventory-WorkflowAssociations -spobject $web -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder
				} #if InventoryWebWorkflowAssociations
				if ($InventoryWebFeatures) {
					Inventory-SPSiteFeatures -web $web -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder
				} #if InventoryWebFeatures
				if ($InventorySiteContentTypes -or
					$InventoryContentTypeWorkflowAssociations
				) {
					#todo look for wf associations at site content type level?
					Write-Host "      Inventorying $Area(s) in $($web.url)..." -ForegroundColor DarkCyan
					Inventory-ContentTypes -SPObject $web -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder -InventoryContentTypeWorkflowAssociations:$InventoryContentTypeWorkflowAssociations
				} #if InventoryListcontentTypes
				if (
					$InventoryLists -or
					$InventoryListWorkflowAssociations -or 
					$InventoryListFields -or 
					$InventoryListViews -or
					$InventoryListContentTypes -or
					$InventoryContentTypeWorkflowAssociations
				) {
					Inventory-SPLists `
                        -web $web `
                        -LogFilePrefix $LogFilePrefix `
                        -DestinationFolder $DestinationFolder `
						-InventoryListWorkflowAssociations:$InventoryListWorkflowAssociations `
                        -InventoryListFields:$InventoryListFields `
                        -InventoryListViews:$InventoryListViews `
						-InventoryListContentTypes:$InventoryListContentTypes `
						-InventoryContentTypeWorkflowAssociations:$InventoryContentTypeWorkflowAssociations
				} #if InventoryLists
				if ($InventoryWebParts) {
					Inventory-SPFolders `
                        -folder $web.rootfolder `
                        -fileprocessfunction "Inventory-Webparts" `
                        -LogFilePrefix $LogFilePrefix `
                        -DestinationFolder $DestinationFolder
				} #if InventoryWebParts
				if ($InventoryWebPermissions) {
					Inventory-SPWebUniquePermissions -web $web -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder
				} #if InventoryWebParts
			} #try
			catch {
				Record-Error $Location $Area $error[0] $LogFilePrefix $DestinationFolder
			} #catch
			finally {
				$web.dispose()
			} #finally
		} #foreach web
	} #process
	END {
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name) complete." -ForegroundColor DarkCyan 
	} #end
 }

function Inventory-SPWebUniquePermissions {
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]$web,
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder
	)
	BEGIN {
		$Area="Site Groups"
		Write-Host "  Inventorying $Area(s) in $($web.url)..." -ForegroundColor DarkCyan
		$groups=$web.sitegroups
		$users=$web.users
		$logfilename=($DestinationFolder + "\" + $LogFilePrefix + "WebUniquePermissions.csv")
		if (-not (test-path $logfilename)) {
			$row = '"Location","Url","GUID","ParentID","GroupName","UserName","Roles"'
			$row | Out-File $logfilename
		}
	} #begin
	PROCESS {
		$counter = 0
		if ($web.HasUniquePerm) {
			$Location=$web.Url
			foreach ($group in $groups) {
				try {
					$groupName=$group.Name
					#$group
					$roles=$group.roles
					$rolelist=$null
					foreach ($role in $roles) {
						$rolelist+=($role.Name + ";")
					} #foreach role
					foreach ($member in $group.users) {
						$userName=$member.loginname
						$row=''
						$row='"'+"Web"+'","'+$web.url+'","'+$web.id+'","'+$web.parentwebid+'","'+$groupName+'","'+$userName+'","'+$rolelist+'"'
						$row | Out-File $logfilename -append
					} #foreach groupmember
					$counter++
				} #try
				catch {
					Record-Error $Location $Area $error[0] $LogFilePrefix $DestinationFolder
				} #catch
			} #foreach group
			foreach ($user in $users) {
				try {
					$groupName=""
					$userName=$user.loginname
					$rolelist=$null
					$roles=$user.roles
					foreach ($role in $roles) {
						$rolelist+=($role.Name + ";")
					} #foreach role
					$row=''
					$row='"'+"Web"+'","'+$web.url+'","'+$web.id+'","'+$web.parentwebid+'","'+$groupName+'","'+$userName+'","'+$rolelist+'"'
					$row | Out-File $logfilename -append
					$counter++
				} #try
				catch {
					Record-Error $Location $Area $error[0] $LogFilePrefix $DestinationFolder
				} #catch
			} #foreach user
		} #if web has unique permissions
		Inventory-SPListUniquePermissions -web $web -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder
	} #process
	END {
		$web.dispose()
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name) complete. $counter $Area(s) inventoried." -ForegroundColor DarkCyan 
	} #end
}

function Inventory-SPListUniquePermissions {
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]$web,
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder
	) #param
	BEGIN {
		$Area="List Unique Permissions"
		$lists=$web.lists
		$Location=$web.url
		Write-Host "  Inventorying $Area(s) in site $($web.url)..." -ForegroundColor DarkCyan
	} #begin
	PROCESS {
		foreach ($list in $lists) {
			try {
                if ($list.HasUniqueRoleAssignments) {
    				$Url = ($list.parentweb.url+$list.url)
                    $Id=$list.id
    				$parentId=$list.parentweb.id
    				$parentWebID=$list.parentweb.id
    				Record-RoleDefinitionBindings `
                        -SPObject $list `
                        -LogFilePrefix $LogFilePrefix `
                        -DestinationFolder $DestinationFolder `
                        -Location $Area `
                        -Url $Url `
                        -Id $Id `
                        -parentId $parentId `
                        -parentWebId $parentWebId
    			} #if unique permissions
            } #try
            catch {
                Record-Error $Location $Area $error[0] $LogFilePrefix $DestinationFolder
            } #catch
            finally {
            
            } #finally
        } #foreach list
		Inventory-SPItemUniquePermissions -list $list -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder
		Inventory-SPFolderUniquePermissions -list $list -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder
	} #process
	END {
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name) complete." -ForegroundColor DarkCyan 
	} #end
}

function Inventory-SPItemUniquePermissions {
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]$list,
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder
	) #param
	BEGIN {
		$Area="Item Unique Permissions"
		$items=$list.items
		$Location=$list.url
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name)..." -ForegroundColor DarkCyan 
	} #begin
	PROCESS {
		foreach ($items in $items) {
			try {
				if ($item.HasUniqueRoleAssignments) {
					$Url=($item.parentlist.parentweb.url +"/"+$item.url)
					$Id=$item.UniqueId
					$parentId=$item.parentlist.id
					$parentWebID=$item.parentlist.parentweb.id
					Record-RoleDefinitionBindings `
						-SPObject $item `
						-LogFilePrefix $LogFilePrefix `
						-DestinationFolder $DestinationFolder `
						-Location $Area `
						-Url $Url `
						-Id $Id `
						-parentId $parentId `
						-parentWebId $parentWebId
				} #if unique permissions
			} #try
            catch {
                Record-Error $Location $Area $error[0] $LogFilePrefix $DestinationFolder
            } #catch
		} #foreach item
	} #process
	END {
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name) complete." -ForegroundColor DarkCyan 
	} #end
}

function Inventory-SPFolderUniquePermissions {
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]$list,
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder
	) #param
	BEGIN {
		Write-Host "  Inventorying Folder Unique Permissions in farm $($farm.Name)..." -ForegroundColor DarkCyan 
		$Location="Folder"
		$folders=$list.folders
	} #begin
	PROCESS {
		foreach ($folder in $folders) {
			if ($folder.HasUniqueRoleAssignments) {
				$Url=($folder.parentlist.parentweb.url +"/"+$folder.url)
				$Id=$folder.UniqueId
				$parentId=$folder.parentlist.id
				$parentWebID=$folder.parentlist.parentweb.id
				Record-RoleDefinitionBindings `
                    -SPObject $folder `
                    -LogFilePrefix $LogFilePrefix `
                    -DestinationFolder $DestinationFolder `
                    -Location $Location `
                    -Url $Url `
                    -Id $Id `
                    -parentId $parentId `
                    -parentWebId $parentWebId
			} #if unique permissions
		} #foreach folder
	} #process
	END {
		Write-Host "  Inventorying Folder Unique Permissions in farm $($farm.Name) complete." -ForegroundColor DarkCyan 
} #end
}

function Record-RoleDefinitionBindings {
	[cmdletbinding()]
	param (
        [Parameter(Mandatory=$true)]$SPObject, #can be list,folder,item so it is not strongly typed
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder,
		[Parameter(Mandatory=$true)][string]$Location,
        [Parameter(Mandatory=$true)][string]$Url,
        [Parameter(Mandatory=$true)][string]$Id,
        [Parameter(Mandatory=$true)][string]$parentId,
		[Parameter(Mandatory=$true)][string]$parentWebId
    )
	BEGIN {
		$logfilename=($DestinationFolder + "\" + $LogFilePrefix + "RoleAssignments.csv")
		$roleAssignment=$SPObject.roleassignments
		if (-not (test-path $logfilename)) {
			$row = '"Location","Url","GUID","ParentID","ParentWebID","Member","Role"'
			$row | Out-File $logfilename
		}
	} #begin
	PROCESS {
		foreach ($roleAssignment in $roleAssignment) {
			$member=$roleAssignment.Member
			$RoleDefinition=""
			$roleDefinitionBindings=$roleAssignment.RoleDefinitionBindings
			foreach ($roleDefinitionBinding in $roleDefinitionBindings) {
				$RoleDefinition+=($roleDefinitionBinding.Name + ";")
			} #foreach RoleDefinitionBinding
			$row=''
			$row='"'+$Location+'","'+$Url+'","'+$Id+'","'+$parentId+'","'+$parentWebId+'","'+$Member+'","'+$RoleDefinition+'"'
			$row | Out-File $logfilename -append
		} #foreach RoleAssignment
	} #process
	END {} #end
}

function Inventory-SPLists {
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]$web,
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder,
		[switch]$InventoryListWorkflowAssociations,
		[switch]$InventoryListFields,
		[switch]$InventoryListViews,
		[switch]$InventoryListContentTypes,
		[switch]$InventoryContentTypeWorkflowAssociations
	) #param
	BEGIN {
		$Area="Lists"
        $now=get-date
		Write-Host "  Inventorying $Area(s) in site $($web.url)..." -ForegroundColor DarkCyan
		$logfilename=($DestinationFolder + "\" + $LogFilePrefix + "Lists.csv")
		if (-not (test-path $logfilename)) {
			#todo get systemlistproperty if possible
			$row = '"ListName","RootFolder","WebUrl","ItemCount","ListTemplate","ListLastModified","EmailAlias","EnableVersioning","EnableMinorVersions","MajorVersionLimit","MajorWithMinorVersionsLimit","ListID"' 
			$row |  out-file $logfilename -append
		}
		$lists=$web.lists
	} #begin
	PROCESS {
		foreach ($list in $lists) {
			try {
				write-host "      Inventorying list $($list.title)..." -ForegroundColor DarkCyan
				$thisListTitle=$list.title
                $Location=($web.Url+$list.RootFolder)
				$Pattern = '"'
				$thisListTitle = [regex]::replace($thisListTitle, $Pattern, '')
				$row='"'+$thisListTitle+'","'+$list.RootFolder+'","'+$web.Url+'","'+$list.ItemCount+'","'+$list.BaseTemplate+'","'+$list.LastItemModifiedDate+'","'+$list.EmailAlias+'","'+$list.EnableVersioning+'","'+$list.EnableMinorVersions+'","'+$list.MajorVersionLimit+'","'+$list.MajorWithMinorVersionsLimit+'","'+$list.id+'"'
				$row | Out-File $logfilename -append
				if ($InventoryListWorkflowAssociations) {
					Inventory-WorkflowAssociations -spobject $list -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder
				} #if InventoryListWorkflowAssociations
				if ($InventoryListFields) {
					Inventory-SPListFields -list $list -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder
				} #if InventoryListFields
				if ($InventoryListViews) {
					Inventory-SPListViews -list $list -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder
				} #if InventoryListViews
				if (
					$InventoryListContentTypes -or
					$InventoryContentTypeWorkflowAssociations
				) {
					write-host "        Inventorying Content Types in list $($list.title)..." -ForegroundColor DarkCyan
					Inventory-ContentTypes -SPObject $list -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder -InventoryContentTypeWorkflowAssociations:$InventoryContentTypeWorkflowAssociations
				} #if InventoryListcontentTypes
			} #try
			catch {
				Record-Error $Location $Area $error[0] $LogFilePrefix $DestinationFolder
			} #catch
			finally {
				$web.dispose()
			} #finally
		} #foreach web
	} #process
	END {
		$web.dispose()
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name) complete." -ForegroundColor DarkCyan 
	} #end
 }

function Inventory-SPListFields {
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]$list,
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder
	) #param
	BEGIN {
		$Area="ListFields"
        $Location=($list.parentweb.Url+$list.RootFolder)
        $now=get-date
		Write-Host "  Inventorying $Area(s) in $($list.title)..." -ForegroundColor DarkCyan
		$logfilename=($DestinationFolder + "\" + $LogFilePrefix + "ListFields.csv")
		if (-not (test-path $logfilename)) {
			$row = '"FieldName","ListDefaultUrl","ViewUrl","WebUrl","FieldType","ListID"' 
			$row | Out-File $logfilename -append
		}
		$fields=$list.fields
	} #begin
	PROCESS {
		foreach ($field in $fields) {
			try {
				$Pattern = '"'
				$thisFieldTitle=$field.Title
				$thisFieldTitle=[regex]::replace($thisFieldTitle, $Pattern, '')
				$row='"'+$thisFieldTitle+'","'+$list.DefaultViewUrl+'","'+$list.DefaultViewUrl+'","'+$list.parentweb.Url+'","'+$field.TypeAsString+'","'+$list.id+'"'
				$row | Out-File $logfilename -append
			} #try
			catch {
				Record-Error $Location $Area $error[0] $LogFilePrefix $DestinationFolder
			} #catch
			finally {
				$web.dispose()
			} #finally
		} #foreach web
	} #process
	END {
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name) complete." -ForegroundColor DarkCyan 
	} #end
 }

function Inventory-SPListViews {
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]$list,
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder
	) #param
	BEGIN {
		$Area="ListViews"
        $Location=($web.Url+$list.RootFolder)
        $now=get-date
		Write-Host "  Inventorying $ListViews in $($list.title)..." -ForegroundColor DarkCyan
		$logfilename=($DestinationFolder + "\" + $LogFilePrefix + "ListViews.csv")
		if (-not (test-path $logfilename)) {
			$row = '"ViewName","ListDefaultUrl","ViewUrl","WebUrl","ViewRowlimit","ViewPaged","ViewType","ListID"' 
			$row | Out-File $logfilename -append
		}
		$views=$list.views
	} #begin
	PROCESS {
		foreach ($view in $views) {
			try {
				$row=''
				$viewType=''
				[xml]$viewprop=$view.propertiesXml
				$viewType=$viewprop.View.Type
				$thisViewTitle=$view.Title
				$Pattern = '"'
				$thisViewTitle=[regex]::replace($thisViewTitle, $Pattern, '')
				$row='"'+$thisViewTitle+'","'+$list.DefaultViewUrl+'","'+$view.Url+'","'+$web.Url+'","'+$view.RowLimit+'","'+$view.Paged+'","'+$viewType+'","'+$list.id+'"'
				$row | Out-File $logfilename -append
			} #try
			catch {
				Record-Error $Location $Area $error[0] $LogFilePrefix $DestinationFolder
			} #catch
			finally {
				#$web.dispose()
			} #finally
		} #foreach web
	} #process
	END {
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name) complete." -ForegroundColor DarkCyan 	
	} #end
 }
 
function Inventory-SPSiteFeatures {
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]$web,
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder
	) #param
	BEGIN {
		$Area="Site Features"
        $now=get-date
		$Location=$web.url
		Write-Host "  Inventorying $Area(s) in $Location..." -ForegroundColor DarkCyan
		$logfilename=($DestinationFolder + "\" + $LogFilePrefix + "SiteFeatures.csv")
		if (-not (test-path $logfilename)) {
			$row = '"SiteCollection","WebUrl","ScriptRunDate","FeatureID","SearchedScope"'
			$row | Out-File $logfilename
		}
		$features=$web.Features
	} #begin
	PROCESS {
		foreach ($feature in $features) { 
			try {
				$row='' 
				$row='"'+$web.site.Url+'","'+$web.url+'","'+$now+'","'+$feature.DefinitionId+'","Web"'
				$row | Out-File $logfilename -append
			}
			catch {
				Record-Error $Location $Area $error[0] $LogFilePrefix $DestinationFolder
			}
			finally {		
			}
		} #foreach site admin
	} #process
	END {
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name)..." -ForegroundColor DarkCyan 
	} #end
 }
 
function Record-Error($Location, $Area, $Err, $LogFilePrefix, $DestinationFolder) {
	$logfilename=($DestinationFolder + "\" + $LogFilePrefix + "ErrorFile.txt")
    write-host "ERROR RECORDED:" -ForegroundColor Red

	$row="Location:"+$Location
	$row | Out-File $logfilename -append
	Write-Host $row -ForegroundColor Red

	$row="Area:"+$Area
	$row | Out-File $logfilename -append
	Write-Host $row -ForegroundColor Red

	$row="Err:"+$Err
	$row | Out-File $logfilename -append
	Write-Host $row -ForegroundColor Red
}

function Inventory-SPFolders {
	[cmdletbinding()]
    param(
    [Parameter(Mandatory=$true)][Microsoft.SharePoint.SPFolder] $folder,
	[Parameter(Mandatory=$true)]$fileprocessfunction,
    [Parameter(Mandatory=$true)]$LogFilePrefix,
    [Parameter(Mandatory=$true)][string]$DestinationFolder
    ) #Param
	BEGIN {
		Write-Host "  Inventorying Folders in farm $($farm.Name)..." -ForegroundColor DarkCyan 
		$subfolders=$folder.SubFolders
		$files=$folder.Files
        #$processFiles = (Get-command -name “Inventory-WebParts“ -CommandType Function).ScriptBlock
	} #begin
	PROCESS {
		#Write-Host "    Checking Folder $($folder.Name)"
		foreach($subFolder in $subfolders) {
			Inventory-SPFolders `
                -folder $subFolder `
                -fileprocessfunction $fileprocessfunction `
                -LogFilePrefix $LogFilePrefix `
                -DestinationFolder $DestinationFolder
		}
		foreach($file in $files) {
            #Write-Host "    Invoking $fileprocessfunction for $($file.Name)"
			&$fileprocessfunction -file $file -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder
		} #foreach file
	} #process
	END {
		Write-Host "  Inventorying Folders in farm $($farm.Name) complete." -ForegroundColor DarkCyan 
} #end
}

function Inventory-WebParts {
	[cmdletbinding()]
    param(
		[Parameter(Mandatory=$true)][Microsoft.SharePoint.SPFile] $file,
        [Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder
    )
	BEGIN {
		Write-Host "  Inventorying Web Parts in farm $($farm.Name)..." -ForegroundColor DarkCyan 
		$assembly = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
        $limitedSPWebPartManager = $assembly.GetType("Microsoft.SharePoint.WebPartPages.SPLimitedWebPartManager");
        $spWebPartManager = $assembly.GetType("Microsoft.SharePoint.WebPartPages.SPWebPartManager");
        if($file.Name.EndsWith(".aspx") -and $file.Exists) {
			$limitedWPM = $file.GetLimitedWebPartManager([System.Web.UI.WebControls.WebParts.PersonalizationScope]::Shared)
			if( $limitedWPM -ne $null){
				$logfilename=($DestinationFolder + "\" + $LogFilePrefix + "WebParts.csv")
				if (-not (test-path $logfilename)) {
					$row = '"WebPartTitle","WebPartClosed","WebUrl","PageUrl","BrowseableObject","InWPZone"'
					$row | Out-File $logfilename
				}
				$webparts=$limitedWPM.WebParts
			} #if limited web part manager is not null
		} # if aspx and exists
	} #begin
	PROCESS {
        if( $limitedWPM -ne $null){
    		foreach ($webpart in $webparts) {
                #write-host "Checking $($webpart.title)"
    			$bindingFlags = [System.Reflection.BindingFlags]::GetField -bor  [System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic
    			$wpManager = $limitedSPWebPartManager.InvokeMember("m_manager", $bindingFlags, $null, $limitedWPM, $null)
    			$bindingFlags = [System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::InvokeMethod -bor [System.Reflection.BindingFlags]::NonPublic
    			$isOnPage = $spWebPartManager.InvokeMember("IsWebPartOnPage", $bindingFlags, $null, $wpManager, $webpart)
    			try {
    				if ($webpart.GetType().AssemblyQualifiedName.StartsWith("Microsoft.SharePoint.WebPartPages.ErrorWebPart", [System.StringComparison]::InvariantCultureIgnoreCase)) {
    					# Broken/Missing Web Part
    					$assemblyQualifiedName = "missing";
    					$webPartTitle = "Error"
    				} #if error web part
    				elseif (!$webpart.GetType().AssemblyQualifiedName.EndsWith("Culture=neutral, PublicKeyToken=71e9bce111e9429c",  [System.StringComparison]::InvariantCultureIgnoreCase)) {
    					# Non-Microsoft assembly
    					$assemblyQualifiedName = $webpart.GetType().AssemblyQualifiedName;
    					$webPartTitle = $webpart.Title
    				} #if microsoft assembly
    				elseif ($webpart.IsClosed) {
    					#Closed Web Part
    					$assemblyQualifiedName = $webpart.GetType().AssemblyQualifiedName;
    					$webPartTitle = $webpart.Title
    				} #web part closed
    				elseif (!$isOnPage) {
    					#Web Part Not in WP Manager
    					$assemblyQualifiedName = $webpart.GetType().AssemblyQualifiedName;
    					$webPartTitle = $webpart.Title
    				} #if not on page
    				if($assemblyQualifiedName) {
    					$webPartTitle=$webpart.Title
    					#TODO************************************************************************************
    					#fix relative URL to get the web URL
    					$Pattern = '"'
    					$webPartTitle= [regex]::replace($webPartTitle, '"', '')
    					$row = '"'+$webPartTitle+'","'+$webpart.IsClosed+'","'+$file.ParentFolder.ParentWeb.Url+'","'+$file.Url+'","'+$assemblyQualifiedName+'","'+$isOnPage+'"'
    					$row | Out-File $logfilename -append
    				} #if assemblyqualified name
                    else {
                        if ($webpart.GetType().AssemblyQualifiedName) {
                            $assemblyQualifiedName=$webpart.GetType().AssemblyQualifiedName;
                        }
                        else {
                            $assemblyQualifiedName="Not Identified"
                        }
                        $webPartTitle=$webpart.Title
    					$Pattern = '"'
    					$webPartTitle= [regex]::replace($webPartTitle, '"', '')
    					$row = '"'+$webPartTitle+'","'+$webpart.IsClosed+'","'+$file.ParentFolder.ParentWeb.Url+'","'+$file.Url+'","'+$assemblyQualifiedName+'","'+$isOnPage+'"'
    					$row | Out-File $logfilename -append
                    } #else assemblyqualifiedname
    			} #try
    			catch {
    				#write-host "err"$error[0]
    				# Need to catch this error 
    				# The field/property: "ViewId" for type: "Microsoft.SharePoint.Portal.WebControls.CategoryWebPart" differs only 
    				# in case from the field/property: "ViewID". Failed to use non CLS compliant type.
    			} #catch
    			$assemblyQualifiedName = $null
    		} #foreach webpart
        } #if limitedwpm is not null
	} #process
	END {
		if ($limitedWPM) {
			$limitedWPM.Dispose()
		} #if limitedwpm
		Write-Host "  Inventorying Web Parts in farm $($farm.Name) complete." -ForegroundColor DarkCyan 
	} #end
}

function Get-SPWebSize {
    param (
        $web, 
        $indludesubwebs
    )
	BEGIN {
		write-host "    Calculating Web Size for site $($web.Url)..." -ForegroundColor DarkCyan
        [long]$total = 0;
		$folders=$web.Folders
	} #begin
    PROCESS {
        foreach ($folder in $folders) {
            $total += Get-SPFolderSize($folder)
        } #foreach folder
        if ($indludesubwebs) {
    		$webs=$web.Webs
            foreach ($subweb in $webs) {
                $total += (Get-SPWebSize -web $subweb -includesubwebs $includesubwebs)
                #$subweb.Dispose()
            }
        } #if includesubwebs
    } #process
    END {
        return $total
    }
}

function Get-SPFolderSize {
	[cmdletbinding()]
    param (
        $folder
    )
    [long]$folderSize = 0
    foreach ($file in $folder.Files) {
        $folderSize += $file.Length; #bytes
    }
    foreach ($subfolder in $folder.SubFolders) {
        $folderSize += Get-SPFolderSize -folder $subfolder
    }    return $folderSize
}

function Inventory-ContentTypes {
	[cmdletbinding()]
	param (
        [Parameter(Mandatory=$true)]$SPObject, #can be site,web or list so it is not strongly typed
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder,
		[switch]$InventoryContentTypeWorkflowAssociations
    )
	BEGIN {
		# Name property may die for some objects?
		$Area="Content Type"
		write-host "  Inventorying $Area(s) in $($SPObject.Title)..." -ForegroundColor DarkCyan
		$Location=$null
		if ($SPObject.Url) {
			$Location=$SPObject.Url
		} elseif ($SPObject.rootfolder) {
			$Location=($SPObject.parentweb.Url+$SPObject.RootFolder)
		}
		$logfilename=($DestinationFolder + "\" + $LogFilePrefix + "ContentTypes.csv")
		$contentTypes=$SPObject.ContentTypes
		if (-not (test-path $logfilename)) {
			$row = '"Location","ContentTypeName","ContentTypeGUID","ParentID","ParentWebID","Hidden","Group","Scope"'
			$row | Out-File $logfilename
		}
		$objectType=$SPObject.gettype()
	} #begin
	PROCESS {
		$counter = 0
		foreach ($contentType in $contentTypes) {
			try {
				#Write-Host "    Logging $($contentType.Name)"
				$row=''
				$row='"'+$objectType+'","'+($contentType.Name)+'","'+($contentType.id)+'","'+($contentType.parent.id)+'","'+($contentType.parentweb.id)+'","'+($contentType.Hiddden)+'","'+($contentType.Group)+'","'+($contentType.Scope)+'"'
				$row | Out-File $logfilename -append
				if ($InventoryContentTypeWorkflowAssociations) {
					Inventory-WorkflowAssociations -spobject $contentType -LogFilePrefix $LogFilePrefix -DestinationFolder $DestinationFolder
				} #if InventoryContentTypeWorkflowAssociations
				$counter++
			} #try
			catch {
				Record-Error $Location $Area $error[0] $LogFilePrefix $DestinationFolder
			}
		} #foreach content type
		
	} #process
	END {
		Write-Host "  Inventorying $Area(s) in $($SPObject.Title) complete.  $counter $Area(s) inventoried." -ForegroundColor DarkCyan
	} #end
}

function Inventory-WorkflowAssociations {
	[cmdletbinding()]
	param (
        [Parameter(Mandatory=$true)]$SPObject, #can be web,content type, or list so it is not strongly typed
		[Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder
    )
	BEGIN {
		$Area = "Workflow Association"
		$now = Get-Date
		write-host "  Inventorying $Area(s) for $($SPObject.Title)..." -ForegroundColor DarkCyan
		$logfilename=($DestinationFolder + "\" + $LogFilePrefix + "WorkflowAssociations.csv")
		if (-not (test-path $logfilename)) {
			$row = '"ObjectType","WorkflowAssociationName","WorkflowAssociationID","ParentAssociationId","ParentContentType","ParentListId","ParentSiteId","ParentWebId","BaseTemplate","Enabled","RunningInstances","WFAParentWebUrl"'
			$row | Out-File $logfilename
		}
		$workflowAssociations=$SPObject.WorkflowAssociations
		$objectType=$SPObject.gettype()
	} #begin
	PROCESS {
		$counter = 0
		if ($WorkflowAssociations) {
			foreach ($wfa in $WorkflowAssociations) {
				Write-Host "    Logging $($wfa.Name)......" -ForegroundColor DarkCyan
				$row=''
				$row='"'+$objectType+'","'+$wfa.Name+'","'+$wfa.id+'","'+$wfa.ParentAssociationId+'","'+$wfa.ParentContentType+'","'+$wfa.ParentList.Id+'","'+$wfa.ParentSite.Id+'","'+$wfa.ParentWeb.Id+'","'+$wfa.BaseTemplate+'","'+$wfa.Enabled+'","'+$wfa.RunningInstances+'","'+$wfa.parentweb.url+'"'
				$row | Out-File $logfilename -append
				$counter++
			} #foreach workflow associations
		} #if WorkflowAssociations
	} #process
	END {
		write-host "  Inventorying $Area(s) for $($SPObject.Title) complete. $counter $Area(s) inventoried." -ForegroundColor DarkCyan
	} #end
}

function Run-FullInventory {
	param (
		$LogFilePrefix="Test_",
		$DestinationFolder="d:\temp",
        [switch]$ClearPriorLogs
	)
    if ($ClearPriorLogs) {
        get-childitem "$DestinationFolder" -filter ($LogFilePrefix+"*.csv") | % {remove-item $_.fullname}
		get-childitem "$DestinationFolder" -filter ($LogFilePrefix+"*.txt") | % {remove-item $_.fullname}
    }
	inventory-spfarm `
		-LogFilePrefix $LogFilePrefix `
		-DestinationFolder $DestinationFolder `
		-InventoryFarmSolutions `
		-InventoryFarmFeatures `
		-InventoryWebTemplates `
		-InventoryWebApplications `
		-InventorySiteCollections `
		-InventorySiteCollectionAdmins `
		-InventorySiteCollectionFeatures `
		-InventoryWebPermissions `
		-InventoryWebs `
		-InventorySiteContentTypes `
		-InventoryWebFeatures `
		-InventoryLists `
		-InventoryWebWorkflowAssociations `
		-InventoryListContentTypes `
        -InventoryListWorkflowAssociations `
        -InventoryContentTypeWorkflowAssociations `
		-InventoryContentDatabases `
		-InventoryListFields `
		-InventoryListViews `
		-InventoryWebParts `
		-InventoryAlternateAccessMappings `
		-InventoryFarmProperties
}

function Inventory-AlternateAccessMappings {
	[cmdletbinding()]
    param(
		[Parameter(Mandatory=$true)]$farm,
        [Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder
    )
	BEGIN {
		$Area = "AlternateAccessMapping"
		$now = Get-Date
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name)..." -ForegroundColor DarkCyan 

		$logfilename=($DestinationFolder + "\" + $LogFilePrefix + $Area + ".csv")
		if (-not (test-path $logfilename)) {
			$row = '"WebAppName","WebAppDisplayName","WebAppStatus","WebAppVersion","IncomingUrl","Uri","UrlZone"'
			$row | Out-File $logfilename
		}

	} #begin
	PROCESS {
		$counter = 0
		foreach($aamCol in $farm.AlternateUrlCollections) {
			foreach($aam in $aamCol){
				$row=''
				$row='"'+$aamCol.Name+'","'+$aamCol.DisplayName+'","'+$aamCol.Status+'","'+$aamCol.Version+'","'+$aam.IncomingUrl+'","'+$aam.Uri+'","'+$aam.UrlZone+'"'
				$row | Out-File $logfilename -append

				$counter++
			} #aam
		} #aamCol
	} #process
	END {

		Write-Host "  Inventorying $Area(s) in farm $($farm.Name) complete. $counter $Area(s) inventoried." -ForegroundColor DarkCyan 
	} #end
}

function Inventory-FarmProperties {
	[cmdletbinding()]
    param(
		[Parameter(Mandatory=$true)]$farm,
        [Parameter(Mandatory=$true)]$LogFilePrefix,
        [Parameter(Mandatory=$true)][string]$DestinationFolder
    )
	BEGIN {
		$Area = "FarmProperties"
		$now = Get-Date
		Write-Host "  Inventorying $Area(s) in farm $($farm.Name)..." -ForegroundColor DarkCyan 

		$logfilename=($DestinationFolder + "\" + $LogFilePrefix + $Area + ".csv")
		if (-not (test-path $logfilename)) {
			$row = '"CanMigrate"' `
				+ ',"PersistedFileChunkSize"' `
				+ ',"BuildVersion"' `
				+ ',"ErrorReportingEnabled"' `
				+ ',"DaysBeforePasswordExpirationToSendEmail"' `
				+ ',"CanUpgrade"' `
				+ ',"PasswordChangeMaximumTries"' `
				+ ',"PasswordChangeEmailAddress"' `
				+ ',"DisableCaching"' `
				+ ',"EnableCaching"' `
				+ ',"BuildVersion"' `
				+ ',"CanBackupRestoreAsConfiguration"' `
				+ ',"CanMigrate"' `
				+ ',"CanRenameOnRestore"' `
				+ ',"CanSelectForBackup"' `
				+ ',"CanSelectForRestore"' `
				+ ',"CanUpgrade"' `
				+ ',"CEIPEnabled"' `
				+ ',"DaysBeforePasswordExpirationToSendEmail"' `
				+ ',"DefaultServiceAccount"' `
				+ ',"DiagnosticsProviders"' `
				+ ',"DiskSizeRequired"' `
				+ ',"DisplayName"' `
				+ ',"DownloadErrorReportingUpdates"' `
				+ ',"EncodedFarmId"' `
				+ ',"ErrorReportingAutomaticUpload"' `
				+ ',"ErrorReportingEnabled"' `
				+ ',"Farm"' `
				+ ',"Id"' `
				+ ',"IsBackwardsCompatible"' `
				+ ',"IsPaired"' `
				+ ',"Name"' `
				+ ',"NeedsUpgrade"' `
				+ ',"NeedsUpgradeIncludeChildren"' `
				+ ',"PairConnectionString"' `
				+ ',"PasswordChangeEmailAddress"' `
				+ ',"PasswordChangeGuardTime"' `
				+ ',"PasswordChangeMaximumTries"' `
				+ ',"PersistedFileChunkSize"' `
				+ ',"Products"' `
				+ ',"ServerDebugFlags"' `
				+ ',"Servers"' `
				+ ',"ServiceApplicationProxyGroups"' `
				+ ',"ServiceProxies"' `
				+ ',"SiteSubscriptions"' `
				+ ',"Status"' `
				+ ',"TimerService"' `
				+ ',"TraceSessionGuid"' `
				+ ',"UpgradeContext"' `
				+ ',"UpgradedPersistedProperties"' `
				+ ',"UseMinWidthForHtmlPicker"' `
				+ ',"UserLicensingEnabled"' `
				+ ',"Version"' `
				+ ',"XsltTransformTimeOut"'
			$row | Out-File $logfilename
		}

	} #begin
	PROCESS {
		$counter = 0
		# Build one wide row of farm properties
		$row=''
		$row= '"' + $farm.CanMigrate + '"' `
		+ ',"' + $farm.PersistedFileChunkSize + '"' `
		+ ',"' + $farm.BuildVersion + '"' `
		+ ',"' + $farm.ErrorReportingEnabled + '"' `
		+ ',"' + $farm.DaysBeforePasswordExpirationToSendEmail + '"' `
		+ ',"' + $farm.CanUpgrade + '"' `
		+ ',"' + $farm.PasswordChangeMaximumTries + '"' `
		+ ',"' + $farm.PasswordChangeEmailAddress + '"' `
		+ ',"' + $farm.DisableCaching + '"' `
		+ ',"' + $farm.EnableCaching + '"' `
		+ ',"' + $farm.BuildVersion + '"' `
		+ ',"' + $farm.CanBackupRestoreAsConfiguration + '"' `
		+ ',"' + $farm.CanMigrate + '"' `
		+ ',"' + $farm.CanRenameOnRestore + '"' `
		+ ',"' + $farm.CanSelectForBackup + '"' `
		+ ',"' + $farm.CanSelectForRestore + '"' `
		+ ',"' + $farm.CanUpgrade + '"' `
		+ ',"' + $farm.CEIPEnabled + '"' `
		+ ',"' + $farm.DaysBeforePasswordExpirationToSendEmail + '"' `
		+ ',"' + $farm.DefaultServiceAccount + '"' `
		+ ',"' + $farm.DiagnosticsProviders + '"' `
		+ ',"' + $farm.DiskSizeRequired + '"' `
		+ ',"' + $farm.DisplayName + '"' `
		+ ',"' + $farm.DownloadErrorReportingUpdates + '"' `
		+ ',"' + $farm.EncodedFarmId + '"' `
		+ ',"' + $farm.ErrorReportingAutomaticUpload + '"' `
		+ ',"' + $farm.ErrorReportingEnabled + '"' `
		+ ',"' + $farm.Farm + '"' `
		+ ',"' + $farm.Id + '"' `
		+ ',"' + $farm.IsBackwardsCompatible + '"' `
		+ ',"' + $farm.IsPaired + '"' `
		+ ',"' + $farm.Name + '"' `
		+ ',"' + $farm.NeedsUpgrade + '"' `
		+ ',"' + $farm.NeedsUpgradeIncludeChildren + '"' `
		+ ',"' + $farm.PairConnectionString + '"' `
		+ ',"' + $farm.PasswordChangeEmailAddress + '"' `
		+ ',"' + $farm.PasswordChangeGuardTime + '"' `
		+ ',"' + $farm.PasswordChangeMaximumTries + '"' `
		+ ',"' + $farm.PersistedFileChunkSize + '"' `
		+ ',"' + $farm.Products + '"' `
		+ ',"' + $farm.ServerDebugFlags + '"' `
		+ ',"' + $farm.Servers + '"' `
		+ ',"' + $farm.ServiceApplicationProxyGroups + '"' `
		+ ',"' + $farm.ServiceProxies + '"' `
		+ ',"' + $farm.SiteSubscriptions + '"' `
		+ ',"' + $farm.Status + '"' `
		+ ',"' + $farm.TimerService + '"' `
		+ ',"' + $farm.TraceSessionGuid + '"' `
		+ ',"' + $farm.UpgradeContext + '"' `
		+ ',"' + $farm.UpgradedPersistedProperties + '"' `
		+ ',"' + $farm.UseMinWidthForHtmlPicker + '"' `
		+ ',"' + $farm.UserLicensingEnabled + '"' `
		+ ',"' + $farm.Version + '"' `
		+ ',"' + $farm.XsltTransformTimeOut + '"'

		$row | Out-File $logfilename -append

		$counter++
	} #process
	END {

		Write-Host "  Inventorying $Area(s) in farm $($farm.Name) complete. $counter $Area(s) inventoried." -ForegroundColor DarkCyan 
	} #end
}