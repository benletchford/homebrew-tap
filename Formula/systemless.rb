class Systemless < Formula
  desc "High-level runtime for classic 68k Macintosh applications"
  homepage "https://systemless.org/"
  url "https://github.com/benletchford/systemless/archive/refs/tags/v0.80.0.tar.gz"
  sha256 "e15f6ca816e03e42ceae728ecabc24dfaa72376586732f2be13ac9ae023c423a"
  license all_of: ["GPL-3.0-or-later", "OFL-1.1"]
  head "https://github.com/benletchford/systemless.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/benletchford/homebrew-tap/releases/download/systemless-0.80.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "10873b5aca8547c90d326eb5927e3bbbba8d5515ad40d22440449a8624a66a2e"
    sha256 cellar: :any_skip_relocation, sequoia:      "64d17a354bb81f7c37424fd4dbd7b13dbf3557af21a39560694ccbd9d188d720"
    sha256 cellar: :any,                 x86_64_linux: "939e459e76ba8f45538ec0810de483ee2a358aacf4392838168ac96c68da1019"
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
