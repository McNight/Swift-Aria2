#include "handle.h"

using namespace CxxAria2;

DownloadHandle::DownloadHandle(aria2::DownloadHandle* h) {
    this->handle = h;
}

aria2::DownloadStatus DownloadHandle::getStatus() const {
    return this->handle->getStatus();
}

int64_t DownloadHandle::getTotalLength() const {
    return this->handle->getTotalLength();
}

int64_t DownloadHandle::getCompletedLength() const {
    return this->handle->getCompletedLength();
}

int64_t DownloadHandle::getUploadLength() const {
    return this->handle->getUploadLength();
}

std::string DownloadHandle::getBitfield() const {
    return this->handle->getBitfield();
}

int DownloadHandle::getDownloadSpeed() const {
    return this->handle->getDownloadSpeed();
}

int DownloadHandle::getUploadSpeed() const {
    return this->handle->getUploadSpeed();
}

const std::string& DownloadHandle::getInfoHash() const {
    return this->handle->getInfoHash();
}

std::size_t DownloadHandle::getPieceLength() const {
    return this->handle->getPieceLength();
}

int DownloadHandle::getNumPieces() const {
    return this->handle->getNumPieces();
}

int DownloadHandle::getConnections() const {
    return this->handle->getConnections();
}

int DownloadHandle::getErrorCode() const {
    return this->handle->getErrorCode();
}

const std::vector<aria2::A2Gid>& DownloadHandle::getFollowedBy() const {
    return this->handle->getFollowedBy();
}

aria2::A2Gid DownloadHandle::getFollowing() const {
    return this->handle->getFollowing();
}

aria2::A2Gid DownloadHandle::getBelongsTo() const {
    return this->handle->getBelongsTo();
}

const std::string DownloadHandle::getDir() const {
    return this->handle->getDir();
}

const std::vector<aria2::FileData> DownloadHandle::getFiles() const {
    return this->handle->getFiles();
}

int DownloadHandle::getNumFiles() const {
    return this->handle->getNumFiles();
}

aria2::FileData DownloadHandle::getFile(int index) const {
    return this->handle->getFile(index);
}

aria2::BtMetaInfoData DownloadHandle::getBtMetaInfo() const {
    return this->handle->getBtMetaInfo();
}

const std::string& DownloadHandle::getOption(const std::string& name) const {
    return this->handle->getOption(name);
}

aria2::KeyVals DownloadHandle::getOptions() const {
    return this->handle->getOptions();
}
