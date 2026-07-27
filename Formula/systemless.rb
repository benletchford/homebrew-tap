class Systemless < Formula
  desc "High-level runtime for classic 68k Macintosh applications"
  homepage "https://systemless.org/"
  url "https://github.com/benletchford/systemless/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "a2ff05d60d2c1cca3bafb7e56eddd6c9680c5a04d0ba3e98727982e47bc68fbf"
  license all_of: ["GPL-3.0-or-later", "OFL-1.1"]
  head "https://github.com/benletchford/systemless.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/benletchford/homebrew-tap/releases/download/systemless-0.6.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "47adc45529f8296a6534077f6c0476b9347c05190a12a318a6872d0593195a4d"
    sha256 cellar: :any_skip_relocation, sequoia:      "f8650a9d596f064609b710365aa48c71676f1d97e29b0b0ee691d89ed425fe1f"
    sha256 cellar: :any,                 x86_64_linux: "7993d49af449806f4dcb1afe6d4fa28a6701e8c8161da36f4ea14faef44b59b8"
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
