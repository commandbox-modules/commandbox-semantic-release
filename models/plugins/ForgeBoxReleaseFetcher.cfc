component implements="interfaces.ReleaseFetcher" {

    property name="configService" inject="configService";
    property name="forgebox" inject="ForgeBox";

    public string function run( required string slug ) {
        var APIToken = configService.getSetting( "endpoints.forgebox.APIToken", "" );
        try {
            var entry = forgebox.getEntry( slug );
        }
        catch ( forgebox e ) {
            return "0.0.0";
        }
        return structIsEmpty( entry.latestVersion ) ? "0.0.0" : entry.latestVersion.version;
    }

}
