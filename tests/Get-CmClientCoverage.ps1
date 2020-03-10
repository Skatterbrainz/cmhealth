param (
	[parameter(Mandatory)][ValidateNotNull()][hashtable] $ScriptParams
)
$query = "select distinct COALESCE(Client_Version0,'NONE'), count(*) as Qty from v_r_system group by Client_Version0"
, @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -query $query)
