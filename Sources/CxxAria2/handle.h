#include "aria2.h"

namespace CxxAria2 {

class DownloadHandle {
public:
    DownloadHandle(aria2::DownloadHandle* h);

    aria2::DownloadStatus getStatus() const;

    int64_t getTotalLength() const;

    int64_t getCompletedLength() const;

    int64_t getUploadLength() const;

    std::string getBitfield() const;

    int getDownloadSpeed() const;

    int getUploadSpeed() const;

    const std::string& getInfoHash() const;

    std::size_t getPieceLength() const;

    int getNumPieces() const;

    int getConnections() const;

    int getErrorCode() const;

    const std::vector<aria2::A2Gid>& getFollowedBy() const;

    aria2::A2Gid getFollowing() const;

    aria2::A2Gid getBelongsTo() const;

    const std::string getDir() const;

    const std::vector<aria2::FileData> getFiles() const;

    int getNumFiles() const;

    aria2::FileData getFile(int index) const;

    aria2::BtMetaInfoData getBtMetaInfo() const;

    const std::string& getOption(const std::string& name) const;

    aria2::KeyVals getOptions() const;

//    ~NonAbstractDownloadHandle() {
//        aria2::deleteDownloadHandle(this->handle);
//    }

private:
    aria2::DownloadHandle *handle;
};

}
