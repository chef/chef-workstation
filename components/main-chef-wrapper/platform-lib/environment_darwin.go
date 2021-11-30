package platform_lib


type EnvInfo struct {
	ChefWorkstation ChefWorkstationInfo
	Ruby RubyInfo
	Path []string
}


type ChefWorkstationInfo struct {
	Version string
	Home string
	InstallDirectory string
	PolicyfileConfig PolicyFileConfigInfo
}
type RubyInfo struct{
	Executable string
	version string
	RubyGems GemInfo
}

type GemInfo struct{
	RubyGemsVersion string
	RubyGemsPlatforms []string
	GemEnvironment []string
}

type PolicyFileConfigInfo struct {
	CachePath string
	StoragePath string
}

func RunEnvironment() error {
	return nil
}
