package main

import (
	"fmt"

	// Can't do this one until/unless the a2 repo becomes public:
	// "github.com/chef/a2/lib/logger"
	"github.com/sirupsen/logrus"
	"github.com/spf13/viper"
)

type App struct {
	log    *logrus.Logger
	config *viper.Viper
}

func (a *App) Initialize(appdir string) {
	a.initializeConfig(appdir)
	a.initializeLogging()
}

func (a *App) initializeLogging() {
	a.log = logrus.New()
}

func (a *App) initializeConfig(appdir string) {
	a.config = viper.New()
	a.config.SetConfigName("config") // name of config file (without extension)
	a.config.AddConfigPath(appdir)   // call multiple times to add many search paths
	err := a.config.ReadInConfig()   // Find and read the config file
	if err != nil {                  // Handle errors reading the config file
		panic(fmt.Errorf("Fatal error loading config file: %s \n", err))
	}
}
