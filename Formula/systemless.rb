class Systemless < Formula
  desc "High-level runtime for classic 68k Macintosh applications"
  homepage "https://systemless.org/"
  url "https://github.com/benletchford/systemless/archive/refs/tags/v0.124.0.tar.gz"
  sha256 "aafb9535fa13d2fee8c0ccd5fe18602853d678c29f3ae991954b311d0e1c6b14"
  license all_of: ["GPL-3.0-or-later", "OFL-1.1"]
  head "https://github.com/benletchford/systemless.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/benletchford/homebrew-tap/releases/download/systemless-0.124.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "b37db1d1aa955962b8e7223c1aea00ad55e24bef047d0c9cbaf3c8505d004236"
    sha256 cellar: :any_skip_relocation, sequoia:      "bca90edd8e7cba7707d0323f87ea9113383f0ffc5e2b5a28aa0c2657a5fd606a"
    sha256 cellar: :any,                 x86_64_linux: "99a6e6e2b8c4d73f1a0e657f343706fbd277ef8f8597a9b85d34e9f1236a4e01"
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
