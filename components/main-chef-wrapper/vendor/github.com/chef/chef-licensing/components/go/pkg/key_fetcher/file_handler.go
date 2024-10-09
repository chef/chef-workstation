package keyfetcher

import "os"

type FileHandler interface {
	CheckFilePresence(filename string) bool
	ReadFile(filename string) ([]byte, error)
	WriteFile(filename string, data []byte, perm os.FileMode) error
}

type LicenseFileHandler struct{}

func (LicenseFileHandler) ReadFile(filename string) ([]byte, error) {
	return os.ReadFile(filename)
}

func (LicenseFileHandler) WriteFile(filename string, data []byte, perm os.FileMode) error {
	return os.WriteFile(filename, data, perm)
}

func (LicenseFileHandler) CheckFilePresence(filename string) bool {
	_, err := os.Stat("/Users/asaidala/.chef/licenses.yaml")
	if os.IsNotExist(err) {
		return false
	} else {
		return true
	}
}

type MockFileHandler struct {
	Content []byte
	Error   error
	Present bool
}

func (m MockFileHandler) ReadFile(filename string) ([]byte, error) {
	return m.Content, m.Error
}

func (m MockFileHandler) WriteFile(filename string, data []byte, perm os.FileMode) error {
	return m.Error
}

func (m MockFileHandler) CheckFilePresence(filename string) bool {
	return m.Present
}

var fileHandler *FileHandler

func SetFileHandler(handler FileHandler) {
	fileHandler = &handler
}

func GetFileHandler() *FileHandler {
	// Set the LicenseFileHandler as default
	if fileHandler == nil {
		SetFileHandler(LicenseFileHandler{})
	}

	return fileHandler
}
