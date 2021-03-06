class SnipsPlatformCommon < Formula
  desc "Snips Platform Common"
  homepage "https://snips.ai"

  url "ssh://git@github.com/snipsco/snips-platform.git",
    :using => :git, :tag => "0.60.3", :revision => "36f15ae289ec203aea2437d986a93b83e8710cf1"

  head "ssh://git@github.com/snipsco/snips-platform.git",
    :using => :git, :branch => "develop"

  bottle do
    root_url "https://homebrew.snips.ai/bottles"
    cellar :any_skip_relocation
    sha256 "8ebd3350b16fc849a6e5d817f379d92b1ead3c7677ee9f0da8920759b411b1ed" => :el_capitan
  end

  skip_clean "var/snips"

  def install
    mkdir_p "homebrew/snips"

    # Prepare /usr/share/snips/
    cp_r "snips-template/snips-actions-templates/templates", "homebrew/snips/snips-actions-templates"
    system "scripts/download-demo-assistant.sh", "-d", "-f homebrew/snips/"

    # Prepare /usr/etc/snips.toml
    config_file = "snips-platform-debian/snips-platform-common/etc/snips.toml"
    # Fix up default conf file to match homebrew paths
    inreplace config_file do |s|
      s.gsub! "/usr/share/snips", share/"snips"
      s.gsub! "/var/lib/snips", var/"snips"
    end

    share.install "homebrew/snips"

    etc.install config_file
  end

  def post_install
    (var/"snips").mkpath
    (var/"log/snips").mkpath
  end

  def caveats; <<~EOS
    snips-platform-common has been installed with a default configuration file.
    You can make changes to the configuration by editing:
      #{etc}/snips.toml
  EOS
  end

  test do
    assert_predicate etc/"snips.toml", :exist?, "snips.toml is missing"
    assert_predicate share/"snips/assistant/", :exist?, "Demo assistant is missing"
    assert_predicate share/"snips/snips-actions-templates/", :exist?, "Template files are missing"
    assert_predicate var/"snips", :exist?, "snips working directory is missing"
  end
end
