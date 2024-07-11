package keyfetcher

import "os"

type FileHandler interface {
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

type MockFileHandler struct {
	Content []byte
	Error   error
}

func (m MockFileHandler) ReadFile(filename string) ([]byte, error) {
	return m.Content, m.Error
}

func (m MockFileHandler) WriteFile(filename string, data []byte, perm os.FileMode) error {
	return m.Error
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
