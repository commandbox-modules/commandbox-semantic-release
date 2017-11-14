component implements="interfaces.ReleaseFetcher" {

    property name="configService" inject="configService";
    property name="forgebox" inject="ForgeBox";

    public string function run( required string slug ) {
        var APIToken = configService.getSetting( "endpoints.forgebox.APIToken", "" );
        var entry = forgebox.getEntry( slug );
        return structIsEmpty( entry.latestVersion ) ? "0.0.0" : entry.latestVersion.version;
    }

}
