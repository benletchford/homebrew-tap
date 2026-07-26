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

  bottle do
    root_url "https://github.com/benletchford/homebrew-tap/releases/download/systemless-0.4.2"
    rebuild 2
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "26113e1d11031afa97a633e8289a31ea45770add89209ddf2255985bcb8993a4"
    sha256 cellar: :any_skip_relocation, sequoia:      "8cc000c76c93d0b42bfa4b2ee526d396e0f76c40cf8ab2aa034eb5f56c256058"
    sha256 cellar: :any,                 x86_64_linux: "0261c0d311faf98fd9d44b3b73c2043877c0418f6eea88b0097f1488396b63a5"
  end

  on_linux do
    depends_on "pkgconf" => :build
    depends_on "rust" => :build
    depends_on "alsa-lib"
  end

  on_arm do
    depends_on "rust" => :build
  end

  resource "rust-toolchain" do
    on_intel do
      url "https://static.rust-lang.org/dist/2026-07-16/rust-1.97.1-x86_64-apple-darwin.tar.xz"
      sha256 "891c32ea77b750dccc7fb0ea98e3feb9db3d29fe0cfea5907d002f270c59cf58"
    end
  end

  def install
    if OS.mac? && Hardware::CPU.intel?
      resource("rust-toolchain").stage do
        system "./install.sh", "--prefix=#{buildpath}/rust-toolchain",
               "--components=rustc,rust-std-x86_64-apple-darwin,cargo",
               "--disable-ldconfig"
      end
      ENV.prepend_path "PATH", buildpath/"rust-toolchain/bin"
    end

    system "cargo", "install", *std_cargo_args, "--bin", "systemless"
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/systemless 2>&1", 1)
    assert_match "Error: Game file not found",
                 shell_output("#{bin}/systemless #{testpath}/missing.sit 2>&1", 1)
  end
end
