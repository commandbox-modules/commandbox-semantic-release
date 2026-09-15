component {
    this.name = "semantic-release-tests";
    this.mappings[ "/semanticRelease" ] = getDirectoryFromPath( getCurrentTemplatePath() ) & "../";
    this.mappings[ "/testbox" ] = this.mappings[ "/semanticRelease" ] & "testbox";
    this.mappings[ "/semver" ] = this.mappings[ "/semanticRelease" ] & "modules/semver";
}
