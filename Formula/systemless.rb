class Systemless < Formula
  desc "High-level runtime for classic 68k Macintosh applications"
  homepage "https://systemless.org/"
  url "https://github.com/benletchford/systemless/archive/refs/tags/v0.20.5.tar.gz"
  sha256 "b25b0c5c35fa3a462bdcd71e9c64bd9e65e5e363f3762b8eb82cd380383275fd"
  license all_of: ["GPL-3.0-or-later", "OFL-1.1"]
  head "https://github.com/benletchford/systemless.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/benletchford/homebrew-tap/releases/download/systemless-0.20.5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "f3578babd863bcf08f79f213de6a1337375378b8de16555c9b87736d4b6147c6"
    sha256 cellar: :any_skip_relocation, sequoia:      "c5809891b57e02d76db26e32eea2e5ddea7fa32c78c36e6e122f18ccf3901368"
    sha256 cellar: :any,                 x86_64_linux: "665293999999e5d1837a9882ebd94cd40fdd0584246300ededf2d8e5dae0a599"
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
