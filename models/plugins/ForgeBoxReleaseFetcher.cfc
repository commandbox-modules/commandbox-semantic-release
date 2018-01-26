component implements="interfaces.ReleaseFetcher" {

    property name="configService" inject="configService";
    property name="print"         inject="PrintBuffer";
    property name="forgebox"      inject="ForgeBox";

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
        var APIToken = configService.getSetting( "endpoints.forgebox.APIToken", "" );
        try {
            var entry = forgebox.getEntry( slug, APIToken );
        }
        catch ( forgebox e ) {
            if ( verbose ) {
                print.line()
                    .white( e.message )
                    .line()
                    .toConsole();
            }
            return "0.0.0";
        }
        return structIsEmpty( entry.latestVersion ) ? "0.0.0" : entry.latestVersion.version;
    }

}
