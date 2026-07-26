class Systemless < Formula
  desc "High-level runtime for classic 68k Macintosh applications"
  homepage "https://systemless.org/"
  url "https://github.com/benletchford/systemless/archive/refs/tags/v0.4.2.tar.gz"
  sha256 "8a1460bc4864f9fd870b8c856d74f130c8d74c59ba87b632f9d68cf316e136d2"
  license all_of: ["GPL-3.0-or-later", "OFL-1.1"]
  head "https://github.com/benletchford/systemless.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "rust" => :build

  on_linux do
    depends_on "pkgconf" => :build
    depends_on "alsa-lib"
  end

  def install
    system "cargo", "install", *std_cargo_args, "--bin", "systemless"
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/systemless 2>&1", 1)
    assert_match "Error: Game file not found",
                 shell_output("#{bin}/systemless #{testpath}/missing.sit 2>&1", 1)
  end
end
