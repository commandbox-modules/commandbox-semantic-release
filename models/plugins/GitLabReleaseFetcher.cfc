component implements="interfaces.ReleaseFetcher" {

    property name="systemSettings" inject="SystemSettings";
    property name="print"          inject="PrintBuffer";

    /**
    * Returns the latest version of the package slug.
    *
    * @slug    The slug of the package to find the latest version.
    * @dryRun  Flag to indicate a dry run of the release.
    * @verbose Flag to indicate printing out extra information.
    *
    * @return  The latest version of the package.
    */
    public string function run(
        required string slug,
        boolean dryRun = false,
        boolean verbose = false
    ) {
        var httpResponse = "";
        cfhttp(
            url="#systemSettings.getSystemSetting( "CI_API_V4_URL" )#/projects/#systemSettings.getSystemSetting( "CI_PROJECT_ID" )#/releases",
            result="httpResponse",
            throwonerror="true"
        ) {
            cfhttpparam(
                type="header",
                name="JOB-TOKEN",
                value="#systemSettings.getSystemSetting( "CI_JOB_TOKEN" )#"
            );
        };
        var res = deserializeJSON( httpResponse.filecontent );
        var tag = res.isEmpty() ? "0.0.0" : res.tag_name;
        return left( tag, 1 ) == "v" ? mid( tag, 2, tag.len() - 1 ) : tag;
    }

}
