class Systemless < Formula
  desc "High-level runtime for classic 68k Macintosh applications"
  homepage "https://systemless.org/"
  url "https://github.com/benletchford/systemless/archive/refs/tags/v0.9.13.tar.gz"
  sha256 "1cd5243d6eadcc566bed186fc70b304be0e58312dc42ec3d7c2bfbb5e9a2486a"
  license all_of: ["GPL-3.0-or-later", "OFL-1.1"]
  head "https://github.com/benletchford/systemless.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/benletchford/homebrew-tap/releases/download/systemless-0.9.13"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "5f5cd80f45853c126e607f595a7016fa933674be82eaf1bd9cab618a51b08e35"
    sha256 cellar: :any_skip_relocation, sequoia:      "061abe3e5bed357ef49ed6156e03122221c2f991e9ab413e2d4b7c3e0c07fe3a"
    sha256 cellar: :any,                 x86_64_linux: "80e1568dd295208021dd311d99e49684befb01286b8b1573fb06ad4d4251c4f2"
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
    # Assert only on --version and --help. Both exit 0 and are guaranteed by
    # the argument parser, so upstream CLI changes cannot silently wedge the
    # release pipeline: 0.7.0 moved to clap, which turned the missing-argument
    # exit status from 1 into 2 and blocked the bottle build.
    assert_match version.to_s, shell_output("#{bin}/systemless --version")
    assert_match "Usage:", shell_output("#{bin}/systemless --help")
  end
end
