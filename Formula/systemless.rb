class Systemless < Formula
  desc "High-level runtime for classic 68k Macintosh applications"
  homepage "https://systemless.org/"
  url "https://github.com/benletchford/systemless/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "865cec1d567edb02f8f8284db6598dacf10e8e48efff7629b5e0263bd9f8a964"
  license all_of: ["GPL-3.0-or-later", "OFL-1.1"]
  head "https://github.com/benletchford/systemless.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/benletchford/homebrew-tap/releases/download/systemless-0.5.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "dce418e411e2f5c2e71e5bb65a4ee6da4889a85cd63ba9cb64976e8ef2cb3088"
    sha256 cellar: :any_skip_relocation, sequoia:      "cc4e775c7fe20bc90117e6bfa9a09a0538c5201b81f1247a1e7d17fc68a58bda"
    sha256 cellar: :any,                 x86_64_linux: "df305d225f4f4cc08d0ec7ca4aa6e56a2b06b75eb03ae9e669a69f751f086bcc"
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
