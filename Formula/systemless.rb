class Systemless < Formula
  desc "High-level runtime for classic 68k Macintosh applications"
  homepage "https://systemless.org/"
  url "https://github.com/benletchford/systemless/archive/refs/tags/v0.70.0.tar.gz"
  sha256 "c44c8758f6cbf377331e0baca3199209f4b20fbdfc4bd2830dbdac6e64e452f2"
  license all_of: ["GPL-3.0-or-later", "OFL-1.1"]
  head "https://github.com/benletchford/systemless.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/benletchford/homebrew-tap/releases/download/systemless-0.70.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "82c415c9e9698b0e780fb2adccf6976227505c7d24df3d1f2dbd4713cb33b89e"
    sha256 cellar: :any_skip_relocation, sequoia:      "677d91a428b5781cf61b33573953d904dbd772d7f4e315f53e11a72e44084826"
    sha256 cellar: :any,                 x86_64_linux: "8a997e749feb09102b3517571a6213f9e1f55a327a5e88f447b287fae8468a9f"
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
