<!-- usage documentation: https://expeditor.chef.io/docs/reference/changelog/ -->
<!-- latest_release 0.9.13 -->
## [0.9.13](https://github.com/chef/chef-workstation/tree/0.9.13) (2019-09-11)

#### Merged Pull Requests
- Add kitchen-vcenter and knife-vcenter [#480](https://github.com/chef/chef-workstation/pull/480) ([tas50](https://github.com/tas50))
<!-- latest_release -->

<!-- release_rollup since=0.8.7 -->
### Changes since 0.8.7 release

#### Merged Pull Requests
- Add kitchen-vcenter and knife-vcenter [#480](https://github.com/chef/chef-workstation/pull/480) ([tas50](https://github.com/tas50)) <!-- 0.9.13 -->
- Fix unzip of chef-workstation-app (Electron-App) [#477](https://github.com/chef/chef-workstation/pull/477) ([afiune](https://github.com/afiune)) <!-- 0.9.12 -->
- Update Cookstyle to 5.5 [#478](https://github.com/chef/chef-workstation/pull/478) ([tas50](https://github.com/tas50)) <!-- 0.9.11 -->
- Bump Chef Workstation App to 0.1.13 [#475](https://github.com/chef/chef-workstation/pull/475) ([chef-ci](https://github.com/chef-ci)) <!-- 0.9.10 -->
- Bump Chef Workstation App to 0.1.12 [#470](https://github.com/chef/chef-workstation/pull/470) ([chef-ci](https://github.com/chef-ci)) <!-- 0.9.9 -->
- Update Test Kitchen, mixlib-shellout, and libarchive to the latest [#469](https://github.com/chef/chef-workstation/pull/469) ([tas50](https://github.com/tas50)) <!-- 0.9.8 -->
- Bump ohai to 15.3.1 [#468](https://github.com/chef/chef-workstation/pull/468) ([chef-ci](https://github.com/chef-ci)) <!-- 0.9.7 -->
- Bump chef-cli to 1.0.13 [#466](https://github.com/chef/chef-workstation/pull/466) ([chef-ci](https://github.com/chef-ci)) <!-- 0.9.6 -->
- Bump train-winrm to 0.2.4 [#465](https://github.com/chef/chef-workstation/pull/465) ([chef-ci](https://github.com/chef-ci)) <!-- 0.9.5 -->
- Bump mixlib-install to 3.11.21 [#464](https://github.com/chef/chef-workstation/pull/464) ([chef-ci](https://github.com/chef-ci)) <!-- 0.9.4 -->
- Bump Delivery CLI to 0.0.54 [#463](https://github.com/chef/chef-workstation/pull/463) ([chef-ci](https://github.com/chef-ci)) <!-- 0.9.3 -->
- Update to Ruby 2.6.4 to address 2 CVEs [#457](https://github.com/chef/chef-workstation/pull/457) ([tas50](https://github.com/tas50)) <!-- 0.9.2 -->
- Bump chefstyle to 0.13.3 [#462](https://github.com/chef/chef-workstation/pull/462) ([chef-ci](https://github.com/chef-ci)) <!-- 0.9.1 -->
- Bump cookstyle to 5.4.13 [#461](https://github.com/chef/chef-workstation/pull/461) ([chef-ci](https://github.com/chef-ci)) <!-- 0.9.0 -->
- Bump Delivery CLI to 0.0.53 [#460](https://github.com/chef/chef-workstation/pull/460) ([chef-ci](https://github.com/chef-ci)) <!-- 0.8.20 -->
- Bump inspec-bin to 4.16.0 [#459](https://github.com/chef/chef-workstation/pull/459) ([chef-ci](https://github.com/chef-ci)) <!-- 0.8.19 -->
- Deprecate macOS 10.12 and add macOS 10.15 support [#455](https://github.com/chef/chef-workstation/pull/455) ([jaymalasinha](https://github.com/jaymalasinha)) <!-- 0.8.18 -->
- Bump knife-ec2 to 1.0.14 [#456](https://github.com/chef/chef-workstation/pull/456) ([chef-ci](https://github.com/chef-ci)) <!-- 0.8.17 -->
- Bump test-kitchen to 2.3.1 [#452](https://github.com/chef/chef-workstation/pull/452) ([chef-ci](https://github.com/chef-ci)) <!-- 0.8.16 -->
- Add libGlesV2 to whitelist chef-workstation-app. [#450](https://github.com/chef/chef-workstation/pull/450) ([marcparadise](https://github.com/marcparadise)) <!-- 0.8.15 -->
- Bump cookstyle to 5.3.6 [#446](https://github.com/chef/chef-workstation/pull/446) ([chef-ci](https://github.com/chef-ci)) <!-- 0.8.14 -->
- Bump Chef Workstation App to 0.1.11 [#445](https://github.com/chef/chef-workstation/pull/445) ([chef-ci](https://github.com/chef-ci)) <!-- 0.8.13 -->
- Bump Chef Workstation App to 0.1.10 [#441](https://github.com/chef/chef-workstation/pull/441) ([chef-ci](https://github.com/chef-ci)) <!-- 0.8.12 -->
- Bump cookstyle to 5.2.17 [#437](https://github.com/chef/chef-workstation/pull/437) ([chef-ci](https://github.com/chef-ci)) <!-- 0.8.11 -->
- Bump inspec to 4.12.0 [#435](https://github.com/chef/chef-workstation/pull/435) ([chef-ci](https://github.com/chef-ci)) <!-- 0.8.10 -->
- Bump kitchen-inspec to 1.2.0 [#434](https://github.com/chef/chef-workstation/pull/434) ([chef-ci](https://github.com/chef-ci)) <!-- 0.8.9 -->
- Begin signing MSI&#39;s with renewed Windows Signing Cert [#431](https://github.com/chef/chef-workstation/pull/431) ([schisamo](https://github.com/schisamo)) <!-- 0.8.8 -->
<!-- release_rollup -->

<!-- latest_stable_release -->
## [0.8.7](https://github.com/chef/chef-workstation/tree/0.8.7) (2019-08-12)

#### Merged Pull Requests
- Add Windows 2019 build verification [#415](https://github.com/chef/chef-workstation/pull/415) ([tas50](https://github.com/tas50))
-  Build Chef Workstation as a self contained project w/o depending on the ChefDK project [un-revert] [#414](https://github.com/chef/chef-workstation/pull/414) ([marcparadise](https://github.com/marcparadise))
- Wire up Chefstyle in Buildkite [#410](https://github.com/chef/chef-workstation/pull/410) ([tas50](https://github.com/tas50))
- Remove cucumber, dco, knife-spork [#417](https://github.com/chef/chef-workstation/pull/417) ([marcparadise](https://github.com/marcparadise))
- Update depedencies to current [#422](https://github.com/chef/chef-workstation/pull/422) ([tas50](https://github.com/tas50))
- Update InSpec, kitchen-vagrant, and kitchen-azurerm to the latest [#424](https://github.com/chef/chef-workstation/pull/424) ([tas50](https://github.com/tas50))
- Bump kitchen-ec2 to 3.1.0 and knife-ec2  to 1.0.11 [#426](https://github.com/chef/chef-workstation/pull/426) ([chef-ci](https://github.com/chef-ci))
- Bump cookstyle to 5.1.19 and ohai to 15.2.5 [#427](https://github.com/chef/chef-workstation/pull/427) ([chef-ci](https://github.com/chef-ci))
- Bump nokogiri to 1.10.4 [#428](https://github.com/chef/chef-workstation/pull/428) ([chef-ci](https://github.com/chef-ci))
- Update Chef to 15.2.20 [#429](https://github.com/chef/chef-workstation/pull/429) ([tas50](https://github.com/tas50))
- Bump knife-ec2 to 1.0.12 [#430](https://github.com/chef/chef-workstation/pull/430) ([chef-ci](https://github.com/chef-ci))
<!-- latest_stable_release -->

## [0.7.4](https://github.com/chef/chef-workstation/tree/0.7.4) (2019-07-16)

#### Merged Pull Requests
- Build Chef Workstation as a self contained project w/o depending on the ChefDK project [#400](https://github.com/chef/chef-workstation/pull/400) ([marcparadise](https://github.com/marcparadise))
- Pin Rubygems to 3.0.3 to prevent double bundler [#409](https://github.com/chef/chef-workstation/pull/409) ([tas50](https://github.com/tas50))
- Revert changes that switched to workstation as the point of truth [#411](https://github.com/chef/chef-workstation/pull/411) ([afiune](https://github.com/afiune))
- downgrade rubygems to 3.0.3 [#412](https://github.com/chef/chef-workstation/pull/412) ([afiune](https://github.com/afiune))
- Update to the latest omnibus-software for double bundler detection [#413](https://github.com/chef/chef-workstation/pull/413) ([tas50](https://github.com/tas50))

## [0.6.2](https://github.com/chef/chef-workstation/tree/0.6.2) (2019-07-15)

#### Merged Pull Requests
- Bump ChefDK to 4.2.0 [#408](https://github.com/chef/chef-workstation/pull/408) ([chef-ci](https://github.com/chef-ci))
- Bump Chef Workstation App to 0.1.8 [#406](https://github.com/chef/chef-workstation/pull/406) ([chef-ci](https://github.com/chef-ci))
- Enable RHEL 8 packages [#407](https://github.com/chef/chef-workstation/pull/407) ([jaymalasinha](https://github.com/jaymalasinha))

## [0.5.1](https://github.com/chef/chef-workstation/tree/0.5.1) (2019-07-09)

#### Merged Pull Requests
- Stop building on Ubuntu 14.04 [#386](https://github.com/chef/chef-workstation/pull/386) ([tas50](https://github.com/tas50))
- Update the omnibus readme to reflect reality [#388](https://github.com/chef/chef-workstation/pull/388) ([tas50](https://github.com/tas50))
- Add a chefworkstation docker container [#376](https://github.com/chef/chef-workstation/pull/376) ([tas50](https://github.com/tas50))
- Bump ChefDK to 4.1.7 [#397](https://github.com/chef/chef-workstation/pull/397) ([chef-ci](https://github.com/chef-ci))
- Update rubygems to 3.0.4 and curl to 7.65.1 [#398](https://github.com/chef/chef-workstation/pull/398) ([tas50](https://github.com/tas50))
- Patch the DK dist file now that we have one [#399](https://github.com/chef/chef-workstation/pull/399) ([tas50](https://github.com/tas50))
- Update the omnibus build license to the Chef EULA [#403](https://github.com/chef/chef-workstation/pull/403) ([btm](https://github.com/btm))
- Fix the chef --version command showing the old DK version [#401](https://github.com/chef/chef-workstation/pull/401) ([tas50](https://github.com/tas50))

## [0.4.2](https://github.com/chef/chef-workstation/tree/0.4.2) (2019-06-20)

#### Merged Pull Requests
- Make sure we properly appbundler Chef and InSpec gems [#385](https://github.com/chef/chef-workstation/pull/385) ([tas50](https://github.com/tas50))

## [0.4.1](https://github.com/chef/chef-workstation/tree/0.4.1) (2019-06-07)

#### Merged Pull Requests
- Preparing for Chef Workstation 0.4 release - EULA support [#383](https://github.com/chef/chef-workstation/pull/383) ([tyler-ball](https://github.com/tyler-ball))
- Adding back Jenkins verification scripts temporarily to enable release [#384](https://github.com/chef/chef-workstation/pull/384) ([tyler-ball](https://github.com/tyler-ball))

## [0.3.2](https://github.com/chef/chef-workstation/tree/0.3.2) (2019-05-31)

#### Merged Pull Requests
- Bump bundler/rubygems/openssl [#357](https://github.com/chef/chef-workstation/pull/357) ([tas50](https://github.com/tas50))
- Bump ChefDK to 3.9.0 [#362](https://github.com/chef/chef-workstation/pull/362) ([chef-ci](https://github.com/chef-ci))
- Update rubygems to 2.7.9 [#363](https://github.com/chef/chef-workstation/pull/363) ([tas50](https://github.com/tas50))
- Build with chef 14.12 in omnibus [#364](https://github.com/chef/chef-workstation/pull/364) ([tas50](https://github.com/tas50))
- remove chefx symlink references [#367](https://github.com/chef/chef-workstation/pull/367) ([jtimberman](https://github.com/jtimberman))
- Bump ChefDK to 3.10.1 [#372](https://github.com/chef/chef-workstation/pull/372) ([chef-ci](https://github.com/chef-ci))
- Misc omnibus cleanup from DK [#375](https://github.com/chef/chef-workstation/pull/375) ([tas50](https://github.com/tas50))
- Copying in the latest ChefDK 3 omnibus definitions to fix the Workstation build [#379](https://github.com/chef/chef-workstation/pull/379) ([tyler-ball](https://github.com/tyler-ball))
- Adding missing software definition for omnibus build [#380](https://github.com/chef/chef-workstation/pull/380) ([tyler-ball](https://github.com/tyler-ball))
- Bump ChefDK to 3.11.3 [#381](https://github.com/chef/chef-workstation/pull/381) ([chef-ci](https://github.com/chef-ci))

## [0.2.53](https://github.com/chef/chef-workstation/tree/0.2.53) (2019-03-29)

#### Merged Pull Requests
- disable appx packages; update to latest omnibus [#344](https://github.com/chef/chef-workstation/pull/344) ([marcparadise](https://github.com/marcparadise))
- Bump Delivery CLI to 0.0.52 [#351](https://github.com/chef/chef-workstation/pull/351) ([chef-ci](https://github.com/chef-ci))
- Bump ChefDK to 3.8.14 [#352](https://github.com/chef/chef-workstation/pull/352) ([chef-ci](https://github.com/chef-ci))
- Update omnibus and omnibus-software. Also, add pin for rust version. [#354](https://github.com/chef/chef-workstation/pull/354) ([jonsmorrow](https://github.com/jonsmorrow))
- omnibus 6.0.19 -&gt; 6.0.21 [#356](https://github.com/chef/chef-workstation/pull/356) ([marcparadise](https://github.com/marcparadise))

## [0.2.48](https://github.com/chef/chef-workstation/tree/0.2.48) (2019-01-31)

#### Merged Pull Requests
- Pin delivery-cli version and add subscription [#331](https://github.com/chef/chef-workstation/pull/331) ([jonsmorrow](https://github.com/jonsmorrow))
- Bump Delivery CLI to 0.0.48 [#337](https://github.com/chef/chef-workstation/pull/337) ([chef-ci](https://github.com/chef-ci))
- Bump Delivery CLI to 0.0.50 [#341](https://github.com/chef/chef-workstation/pull/341) ([chef-ci](https://github.com/chef-ci))
- Bump Chef Workstation App to 0.1.7 [#343](https://github.com/chef/chef-workstation/pull/343) ([chef-ci](https://github.com/chef-ci))
- Bump ChefDK to 3.7.23 [#342](https://github.com/chef/chef-workstation/pull/342) ([chef-ci](https://github.com/chef-ci))

## [0.2.43](https://github.com/chef/chef-workstation/tree/0.2.43) (2018-12-28)

#### Merged Pull Requests
- [SHACK-402] Design for local telemetry service [#322](https://github.com/chef/chef-workstation/pull/322) ([marcparadise](https://github.com/marcparadise))
- Bump ChefDK to 3.6.57 [#330](https://github.com/chef/chef-workstation/pull/330) ([chef-ci](https://github.com/chef-ci))

## [0.2.41](https://github.com/chef/chef-workstation/tree/0.2.41) (2018-12-03)

#### Merged Pull Requests
- Begin using release rollup in CHANGELOG [#314](https://github.com/chef/chef-workstation/pull/314) ([schisamo](https://github.com/schisamo))
- Bug - expeditor pointing at wrong file [#315](https://github.com/chef/chef-workstation/pull/315) ([tyler-ball](https://github.com/tyler-ball))
- Bump ChefDK to 3.5.13 [#317](https://github.com/chef/chef-workstation/pull/317) ([chef-ci](https://github.com/chef-ci))
- CoC and Contrib docs [#321](https://github.com/chef/chef-workstation/pull/321) ([marcparadise](https://github.com/marcparadise))
- Fix environment variables in release scripts [#323](https://github.com/chef/chef-workstation/pull/323) ([schisamo](https://github.com/schisamo))
- Pinning ChefDK to unreleased 3.6 to get new bundled gem changes we want [#324](https://github.com/chef/chef-workstation/pull/324) ([tyler-ball](https://github.com/tyler-ball))
- [ChefDK to 3.6.4] Add kitchen-ec2 support for arm64 architecture [#325](https://github.com/chef/chef-workstation/pull/325) ([tyler-ball](https://github.com/tyler-ball))
- Fix env var capitalization in purge-cdn.sh [#326](https://github.com/chef/chef-workstation/pull/326) ([schisamo](https://github.com/schisamo))
- Fixing expeditor failure - wrong variable capitalization [#327](https://github.com/chef/chef-workstation/pull/327) ([tyler-ball](https://github.com/tyler-ball))

## [0.2.29](https://github.com/chef/chef-workstation/tree/0.2.29) (2018-10-29)

#### Merged Pull Requests
- Bump ChefDK to 3.4.38 [#309](https://github.com/chef/chef-workstation/pull/309) ([chef-ci](https://github.com/chef-ci))
- README updated: fixed typo and expanded an example [#307](https://github.com/chef/chef-workstation/pull/307) ([stefanwb](https://github.com/stefanwb))

## [0.2.27](https://github.com/chef/chef-workstation/tree/0.2.27) (2018-10-22)

#### Merged Pull Requests
- Display workstation version in `chef -v` [#304](https://github.com/chef/chef-workstation/pull/304) ([jonsmorrow](https://github.com/jonsmorrow))
- Switch from using git submodules to ignored folders for www dependencies [#305](https://github.com/chef/chef-workstation/pull/305) ([schisamo](https://github.com/schisamo))
- Fix uninstall on troubleshooting [#302](https://github.com/chef/chef-workstation/pull/302) ([jonsmorrow](https://github.com/jonsmorrow))
- Remove chef-workstation-app link on uninstall [#300](https://github.com/chef/chef-workstation/pull/300) ([marcparadise](https://github.com/marcparadise))
- Pin chef-workstation-app version in its software definition [#299](https://github.com/chef/chef-workstation/pull/299) ([marcparadise](https://github.com/marcparadise))
- Bump Chef Workstation App to 0.1.4 [#301](https://github.com/chef/chef-workstation/pull/301) ([chef-ci](https://github.com/chef-ci))

## [0.2.21](https://github.com/chef/chef-workstation/tree/0.2.21) (2018-10-18)

#### Merged Pull Requests
- Do not &#39;replace&#39; chefdk in linux packaging for now [#298](https://github.com/chef/chef-workstation/pull/298) ([marcparadise](https://github.com/marcparadise))
- Do not &#39;replace&#39; chefdk in linux packaging for now [#298](https://github.com/chef/chef-workstation/pull/298) ([marcparadise](https://github.com/marcparadise))
- Bump Chef Workstation App to 0.1.3 [#295](https://github.com/chef/chef-workstation/pull/295) ([chef-ci](https://github.com/chef-ci))
- Add tray to installer welcome text on mac. [#287](https://github.com/chef/chef-workstation/pull/287) ([jonsmorrow](https://github.com/jonsmorrow))
- Update omnibus to use ruby-cleanup [#294](https://github.com/chef/chef-workstation/pull/294) ([tas50](https://github.com/tas50))
- Bump Chef Workstation App to 0.1.2 [#293](https://github.com/chef/chef-workstation/pull/293) ([chef-ci](https://github.com/chef-ci))
- Fixing a bad link in documentation [#292](https://github.com/chef/chef-workstation/pull/292) ([tyler-ball](https://github.com/tyler-ball))
- Fix bad copy-pasta in link address [#291](https://github.com/chef/chef-workstation/pull/291) ([marcparadise](https://github.com/marcparadise))
- Bump Chef Workstation App to 0.1.1 [#290](https://github.com/chef/chef-workstation/pull/290) ([chef-ci](https://github.com/chef-ci))
- post-merge doc updates [#289](https://github.com/chef/chef-workstation/pull/289) ([marcparadise](https://github.com/marcparadise))
- Bump Chef Workstation App to 0.1.0 [#286](https://github.com/chef/chef-workstation/pull/286) ([chef-ci](https://github.com/chef-ci))
- Removing some copyrighted names from examples [#285](https://github.com/chef/chef-workstation/pull/285) ([tyler-ball](https://github.com/tyler-ball))
- Add config reference doc [#288](https://github.com/chef/chef-workstation/pull/288) ([marcparadise](https://github.com/marcparadise))
- Upgrade on linux [#283](https://github.com/chef/chef-workstation/pull/283) ([jonsmorrow](https://github.com/jonsmorrow))
- Fixes tray app upgrades on mac [#282](https://github.com/chef/chef-workstation/pull/282) ([jonsmorrow](https://github.com/jonsmorrow))
- Bump DK version to v3.4.18 [#284](https://github.com/chef/chef-workstation/pull/284) ([jonsmorrow](https://github.com/jonsmorrow))
- Adds in-flight install/upgrade/remove page under Workstation heading [#274](https://github.com/chef/chef-workstation/pull/274) ([marcparadise](https://github.com/marcparadise))
- Adds the in-flight Chef Workstation App doc page [#273](https://github.com/chef/chef-workstation/pull/273) ([marcparadise](https://github.com/marcparadise))
- Adds chef-run user guide under Workstation [#275](https://github.com/chef/chef-workstation/pull/275) ([marcparadise](https://github.com/marcparadise))
- Updates &quot;about.md&quot; for Workstation [#276](https://github.com/chef/chef-workstation/pull/276) ([marcparadise](https://github.com/marcparadise))
- Fix reversed condition for CWA lib detection [#266](https://github.com/chef/chef-workstation/pull/266) ([marcparadise](https://github.com/marcparadise))
- [SHACK-367] Bump minor version for GA [#254](https://github.com/chef/chef-workstation/pull/254) ([jonsmorrow](https://github.com/jonsmorrow))
- Update privacy.md [#277](https://github.com/chef/chef-workstation/pull/277) ([marcparadise](https://github.com/marcparadise))
- Creates about page, edits privacy, edits getting-started [#268](https://github.com/chef/chef-workstation/pull/268) ([kagarmoe](https://github.com/kagarmoe))
- Updating maintainer email to remove beta since Workstation is going GA [#271](https://github.com/chef/chef-workstation/pull/271) ([tyler-ball](https://github.com/tyler-ball))
- Clean up user messaging order in uninstall script [#265](https://github.com/chef/chef-workstation/pull/265) ([jonsmorrow](https://github.com/jonsmorrow))
- Mac uninstall program [#264](https://github.com/chef/chef-workstation/pull/264) ([jonsmorrow](https://github.com/jonsmorrow))
- Uninstall ChefDK when installing CWS on Windows [#262](https://github.com/chef/chef-workstation/pull/262) ([marcparadise](https://github.com/marcparadise))
- Bump Chef Workstation App to 0.0.31 [#263](https://github.com/chef/chef-workstation/pull/263) ([chef-ci](https://github.com/chef-ci))
- Bump Chef Workstation App to 0.0.30 [#261](https://github.com/chef/chef-workstation/pull/261) ([chef-ci](https://github.com/chef-ci))
- Slim down the package and install sizes [#252](https://github.com/chef/chef-workstation/pull/252) ([tas50](https://github.com/tas50))
- Bump Chef Workstation App to 0.0.29 [#259](https://github.com/chef/chef-workstation/pull/259) ([chef-ci](https://github.com/chef-ci))
- Bump Chef Workstation App to 0.0.28 [#258](https://github.com/chef/chef-workstation/pull/258) ([chef-ci](https://github.com/chef-ci))
- Wait for chef-workstation-app merge_actions to finish. [#257](https://github.com/chef/chef-workstation/pull/257) ([jonsmorrow](https://github.com/jonsmorrow))
- Subscribe to Workstation App pr merges [#255](https://github.com/chef/chef-workstation/pull/255) ([jonsmorrow](https://github.com/jonsmorrow))
- Update CHANGELOG.md to capture PR #251 [#253](https://github.com/chef/chef-workstation/pull/253) ([jonsmorrow](https://github.com/jonsmorrow))
- [SHACK-370] Disable windows chef workstation app autostart [#250](https://github.com/chef/chef-workstation/pull/250) ([marcparadise](https://github.com/marcparadise))
- [SHACK-371] Uninstall ChefDK on OSX [#251](https://github.com/chef/chef-workstation/pull/251) ([jonsmorrow](https://github.com/jonsmorrow))
- [SHACK-354] windows install: capture install path to registry  [#249](https://github.com/chef/chef-workstation/pull/249) ([marcparadise](https://github.com/marcparadise))
- [SHACK-358] update docs and navigation for chef.sh [#245](https://github.com/chef/chef-workstation/pull/245) ([marcparadise](https://github.com/marcparadise))
- [SHACK-357] Include latest stable release of ChefDK [#247](https://github.com/chef/chef-workstation/pull/247) ([tyler-ball](https://github.com/tyler-ball))
- Add taskkill action to windows install [#246](https://github.com/chef/chef-workstation/pull/246) ([marcparadise](https://github.com/marcparadise))
- [SHACK-361] Different look for icons on win desktop [#248](https://github.com/chef/chef-workstation/pull/248) ([tyler-ball](https://github.com/tyler-ball))
- [SHACK-352] Enable CWA on Mac OS X [#243](https://github.com/chef/chef-workstation/pull/243) ([marcparadise](https://github.com/marcparadise))
- [SHACK-348] Enable CWA on linux [#242](https://github.com/chef/chef-workstation/pull/242) ([marcparadise](https://github.com/marcparadise))
- [SHACK-353] Enable CWA on Windows [#241](https://github.com/chef/chef-workstation/pull/241) ([marcparadise](https://github.com/marcparadise))
- [SHACK-322]   [#238](https://github.com/chef/chef-workstation/pull/238) ([marcparadise](https://github.com/marcparadise))
- Capitalization issue in Windows package (wix) [#235](https://github.com/chef/chef-workstation/pull/235) ([tyler-ball](https://github.com/tyler-ball))
- Updating OpenSSL to 1.0.2p to fix CVEs [#234](https://github.com/chef/chef-workstation/pull/234) ([tyler-ball](https://github.com/tyler-ball))

## [0.1.162](https://github.com/chef/chef-workstation/tree/0.1.162) (2018-08-09)

#### Merged Pull Requests
- [SHACK-304] Do not update Chef Workstation changelog for ChefDK changes [#233](https://github.com/chef/chef-workstation/pull/233) ([tyler-ball](https://github.com/tyler-ball))

## [0.1.155](https://github.com/chef/chef-workstation/tree/0.1.155) (2018-08-01)

#### Merged Pull Requests
- [SHACK-304] Subscribe to ChefDK merges in expeditor [#232](https://github.com/chef/chef-workstation/pull/232) ([tyler-ball](https://github.com/tyler-ball))
- Minimize Github Issue/PR templates now that Chef Apply is separate project [#229](https://github.com/chef/chef-workstation/pull/229) ([tyler-ball](https://github.com/tyler-ball))

## [0.1.150](https://github.com/chef/chef-workstation/tree/0.1.150) (2018-07-10)

#### Merged Pull Requests
- [SHACK-250] Pull in new chef-apply gem [#228](https://github.com/chef/chef-workstation/pull/228) ([tyler-ball](https://github.com/tyler-ball))
- Add docs to the PR template checklist [#227](https://github.com/chef/chef-workstation/pull/227) ([marcparadise](https://github.com/marcparadise))

## [0.1.148](https://github.com/chef/chef-workstation/tree/0.1.148) (2018-07-03)

#### Merged Pull Requests
- Provide instructions via error message when no auth method is available. [#226](https://github.com/chef/chef-workstation/pull/226) ([marcparadise](https://github.com/marcparadise))
- Revert &quot;Adding expeditor buffers&quot; to fix pipeline [#223](https://github.com/chef/chef-workstation/pull/223) ([marcparadise](https://github.com/marcparadise))
- Fix &#39;unexpected error&#39; on auth failure; ensure auth user always shows on connect [#217](https://github.com/chef/chef-workstation/pull/217) ([marcparadise](https://github.com/marcparadise))
- [SHACK-272] Prefer .ssh/config default values over train&#39;s defaults. [#215](https://github.com/chef/chef-workstation/pull/215) ([marcparadise](https://github.com/marcparadise))
- [SHACK-256] We should be pulling cookbooks from locally configured coookbook repos [#213](https://github.com/chef/chef-workstation/pull/213) ([tyler-ball](https://github.com/tyler-ball))

## [0.1.142](https://github.com/chef/chef-workstation/tree/0.1.142) (2018-06-26)

#### Merged Pull Requests
- [SHACK-252] Ensure that .ssh/config settings are used when not overridden.  [#212](https://github.com/chef/chef-workstation/pull/212) ([marcparadise](https://github.com/marcparadise))
- [SHACK-268] Fix telemetry data not being sent [#210](https://github.com/chef/chef-workstation/pull/210) ([marcparadise](https://github.com/marcparadise))
- Support Automate self signed certs (short term) [#208](https://github.com/chef/chef-workstation/pull/208) ([tyler-ball](https://github.com/tyler-ball))

## [0.1.139](https://github.com/chef/chef-workstation/tree/0.1.139) (2018-06-21)

#### Merged Pull Requests
- Found some missed chef-cli references [#207](https://github.com/chef/chef-workstation/pull/207) ([tyler-ball](https://github.com/tyler-ball))
- Remove chef-cli library [#205](https://github.com/chef/chef-workstation/pull/205) ([marcparadise](https://github.com/marcparadise))

## [0.1.137](https://github.com/chef/chef-workstation/tree/0.1.137) (2018-06-20)

#### Merged Pull Requests
- We no longer need to install bundler because lita workers have ChefDK installed [#206](https://github.com/chef/chef-workstation/pull/206) ([tyler-ball](https://github.com/tyler-ball))
- Create ~/.chef-workstation before config file [#197](https://github.com/chef/chef-workstation/pull/197) ([TrevorBramble](https://github.com/TrevorBramble))
- We should be loading default config using workstation config loader [#153](https://github.com/chef/chef-workstation/pull/153) ([tyler-ball](https://github.com/tyler-ball))
- [SHACK-233] Do not overwrite existing Policyfile [#196](https://github.com/chef/chef-workstation/pull/196) ([tyler-ball](https://github.com/tyler-ball))

## [0.1.133](https://github.com/chef/chef-workstation/tree/0.1.133) (2018-06-08)

#### Merged Pull Requests
- Updating omnibus-software definitions [#195](https://github.com/chef/chef-workstation/pull/195) ([tyler-ball](https://github.com/tyler-ball))
- Fix error that occurs when config file deleted. [#193](https://github.com/chef/chef-workstation/pull/193) ([marcparadise](https://github.com/marcparadise))
- Pass correct config value for protocol [#191](https://github.com/chef/chef-workstation/pull/191) ([marcparadise](https://github.com/marcparadise))
- [SHACK-195] Handle bad configuration errors gracefully. [#190](https://github.com/chef/chef-workstation/pull/190) ([marcparadise](https://github.com/marcparadise))
- [SHACK-213] [GH-178] Add --protocol flag [#181](https://github.com/chef/chef-workstation/pull/181) ([marcparadise](https://github.com/marcparadise))
- [SHACK-210] [GH #180] Perform startup tasks outside of main CLI handling [#183](https://github.com/chef/chef-workstation/pull/183) ([marcparadise](https://github.com/marcparadise))
- [SHACK-212] [GH #175] Always expand host to include full user info [#176](https://github.com/chef/chef-workstation/pull/176) ([marcparadise](https://github.com/marcparadise))
- Removed the nonexistent FAF [#187](https://github.com/chef/chef-workstation/pull/187) ([jjasghar](https://github.com/jjasghar))
- Added 001 to trouble shooting [#182](https://github.com/chef/chef-workstation/pull/182) ([jjasghar](https://github.com/jjasghar))
- Update Omnibus Readme [#170](https://github.com/chef/chef-workstation/pull/170) ([jonsmorrow](https://github.com/jonsmorrow))
- Update CODEOWNERS to new team name [#169](https://github.com/chef/chef-workstation/pull/169) ([jonsmorrow](https://github.com/jonsmorrow))
- Correct run-gif reference in docs [#166](https://github.com/chef/chef-workstation/pull/166) ([tduffield](https://github.com/tduffield))
- [DOCS] formatting and copy edits [#165](https://github.com/chef/chef-workstation/pull/165) ([kagarmoe](https://github.com/kagarmoe))

## [0.1.120](https://github.com/chef/chef-workstation/tree/0.1.120) (2018-05-23)

#### Merged Pull Requests
- Example to use on Chef Conf&#39;s mainstage. [#144](https://github.com/chef/chef-workstation/pull/144) ([jonsmorrow](https://github.com/jonsmorrow))

## [0.1.119](https://github.com/chef/chef-workstation/tree/0.1.119) (2018-05-22)

#### Merged Pull Requests
- page ordering. [#163](https://github.com/chef/chef-workstation/pull/163) ([mchiang0610](https://github.com/mchiang0610))
- Redacting exception message [#161](https://github.com/chef/chef-workstation/pull/161) ([jonsmorrow](https://github.com/jonsmorrow))
- Getting started. [#160](https://github.com/chef/chef-workstation/pull/160) ([mchiang0610](https://github.com/mchiang0610))
- Start of CLI guide. [#147](https://github.com/chef/chef-workstation/pull/147) ([mchiang0610](https://github.com/mchiang0610))
- Telemetry product name is &#39;chef-workstation&#39; [#159](https://github.com/chef/chef-workstation/pull/159) ([marcparadise](https://github.com/marcparadise))
- Revert train to 1.4.6, update sudo error checks [#158](https://github.com/chef/chef-workstation/pull/158) ([marcparadise](https://github.com/marcparadise))
- Ensure that all errors bubble up [#156](https://github.com/chef/chef-workstation/pull/156) ([marcparadise](https://github.com/marcparadise))
- Fix telemetry race condition [#157](https://github.com/chef/chef-workstation/pull/157) ([marcparadise](https://github.com/marcparadise))
- [SHACK-178] add PowerShell customization and shortcuts to Windows install [#152](https://github.com/chef/chef-workstation/pull/152) ([robbkidd](https://github.com/robbkidd))
- [SHACK-42] Add sudo- and auth-related options and text [#139](https://github.com/chef/chef-workstation/pull/139) ([marcparadise](https://github.com/marcparadise))
- Images for OSS Website. [#155](https://github.com/chef/chef-workstation/pull/155) ([ChefRycar](https://github.com/ChefRycar))
- Update circleci to bundle install chef-run [#154](https://github.com/chef/chef-workstation/pull/154) ([marcparadise](https://github.com/marcparadise))
- [SHACK-188] resolve regression on telemetry not actually sending data [#150](https://github.com/chef/chef-workstation/pull/150) ([robbkidd](https://github.com/robbkidd))
- Fixes error handling when an invalid flag is passed. [#151](https://github.com/chef/chef-workstation/pull/151) ([jonsmorrow](https://github.com/jonsmorrow))
- Add note about Apache license. [#148](https://github.com/chef/chef-workstation/pull/148) ([mchiang0610](https://github.com/mchiang0610))
- troubleshooting guide. [#149](https://github.com/chef/chef-workstation/pull/149) ([mchiang0610](https://github.com/mchiang0610))
- start of privacy page. [#146](https://github.com/chef/chef-workstation/pull/146) ([mchiang0610](https://github.com/mchiang0610))
- Fix policyfile  race condition for multitarget [#145](https://github.com/chef/chef-workstation/pull/145) ([marcparadise](https://github.com/marcparadise))
- Missed a ChefCLI =&gt; ChefRun. [#142](https://github.com/chef/chef-workstation/pull/142) ([jonsmorrow](https://github.com/jonsmorrow))
- Updating welcome text for mac package. [#141](https://github.com/chef/chef-workstation/pull/141) ([jonsmorrow](https://github.com/jonsmorrow))
- fix spelling caught during user test. [#137](https://github.com/chef/chef-workstation/pull/137) ([mchiang0610](https://github.com/mchiang0610))
- Update code/instructions for bringing chef.sh up locally  [#140](https://github.com/chef/chef-workstation/pull/140) ([schisamo](https://github.com/schisamo))
- Fix failing integration test on help output [#138](https://github.com/chef/chef-workstation/pull/138) ([marcparadise](https://github.com/marcparadise))
- Shack 199/rename to chef run [#131](https://github.com/chef/chef-workstation/pull/131) ([jonsmorrow](https://github.com/jonsmorrow))
- Include chef-telemetry in packages from rubygems. [#136](https://github.com/chef/chef-workstation/pull/136) ([jonsmorrow](https://github.com/jonsmorrow))
- [SHACK-188] telemetry cleanup tasks [#134](https://github.com/chef/chef-workstation/pull/134) ([marcparadise](https://github.com/marcparadise))
- [SHACK-131] Support custom resources from another cookbook [#126](https://github.com/chef/chef-workstation/pull/126) ([tyler-ball](https://github.com/tyler-ball))
- change possibly confusing sample hostname in usage text [#133](https://github.com/chef/chef-workstation/pull/133) ([jjasghar](https://github.com/jjasghar))
- Some bug fixes / tests as documentation I came across [#127](https://github.com/chef/chef-workstation/pull/127) ([tyler-ball](https://github.com/tyler-ball))
- [SHACK-167] use the real website in the post-install message [#130](https://github.com/chef/chef-workstation/pull/130) ([robbkidd](https://github.com/robbkidd))
- Support SLES and add tests for train translation [#125](https://github.com/chef/chef-workstation/pull/125) ([cheeseplus](https://github.com/cheeseplus))
- rename ChefCLI::Telemtry to ChefCLI::Telemeter [#132](https://github.com/chef/chef-workstation/pull/132) ([marcparadise](https://github.com/marcparadise))
- [SHACK-188] Telemetry power on [#123](https://github.com/chef/chef-workstation/pull/123) ([marcparadise](https://github.com/marcparadise))
- pin train to pre-GCP version [#128](https://github.com/chef/chef-workstation/pull/128) ([robbkidd](https://github.com/robbkidd))
- SHACK-191 Basic Automate 2 Reporting [#119](https://github.com/chef/chef-workstation/pull/119) ([jonsmorrow](https://github.com/jonsmorrow))
- Ensure chef manifest exists before trying to read it [#115](https://github.com/chef/chef-workstation/pull/115) ([tyler-ball](https://github.com/tyler-ball))
- [SHACK-181] Renaming Chef Workstation gem to Chef CLI because that is more true [#114](https://github.com/chef/chef-workstation/pull/114) ([tyler-ball](https://github.com/tyler-ball))
- [SHACK-179] Support for upgrading chef-client [#112](https://github.com/chef/chef-workstation/pull/112) ([marcparadise](https://github.com/marcparadise))
- Cleaning up [#113](https://github.com/chef/chef-workstation/pull/113) ([cheeseplus](https://github.com/cheeseplus))
- Fix chef install for EL derivatives and Amazon Linux [#111](https://github.com/chef/chef-workstation/pull/111) ([cheeseplus](https://github.com/cheeseplus))
- [SHACK-129] Use policyfile for remote code bundle [#109](https://github.com/chef/chef-workstation/pull/109) ([tyler-ball](https://github.com/tyler-ball))
- [SHACK-182] support special password characters in targets via www-form encoding [#110](https://github.com/chef/chef-workstation/pull/110) ([marcparadise](https://github.com/marcparadise))
- include a more complete collection of tooling from DK [#108](https://github.com/chef/chef-workstation/pull/108) ([robbkidd](https://github.com/robbkidd))
- multitarget fixes [#107](https://github.com/chef/chef-workstation/pull/107) ([marcparadise](https://github.com/marcparadise))
- Enable simplecov coverage reporting [#103](https://github.com/chef/chef-workstation/pull/103) ([marcparadise](https://github.com/marcparadise))
- Add more vagrant hosts for multitarget testing [#106](https://github.com/chef/chef-workstation/pull/106) ([marcparadise](https://github.com/marcparadise))
- [SHACK-145] Add handling for multi-target errors [#98](https://github.com/chef/chef-workstation/pull/98) ([marcparadise](https://github.com/marcparadise))
- Add support for ranges in target names. [#105](https://github.com/chef/chef-workstation/pull/105) ([marcparadise](https://github.com/marcparadise))
- Remove notes on upcoming ChefDK compat. [#102](https://github.com/chef/chef-workstation/pull/102) ([mchiang0610](https://github.com/mchiang0610))
- First pass at adding chef.sh www directory [#104](https://github.com/chef/chef-workstation/pull/104) ([tduffield](https://github.com/tduffield))
- Quick bugfix [#101](https://github.com/chef/chef-workstation/pull/101) ([tyler-ball](https://github.com/tyler-ball))
- Fix ubuntu link [#100](https://github.com/chef/chef-workstation/pull/100) ([jonsmorrow](https://github.com/jonsmorrow))
- Add links for linux packages to README.md [#99](https://github.com/chef/chef-workstation/pull/99) ([jonsmorrow](https://github.com/jonsmorrow))
-  [SHACK-145] enable mutlitarget support for &#39;converge&#39; [#97](https://github.com/chef/chef-workstation/pull/97) ([marcparadise](https://github.com/marcparadise))
- [SHACK-144] Add mocks for multi-target converges [#92](https://github.com/chef/chef-workstation/pull/92) ([marcparadise](https://github.com/marcparadise))
- [SHACK-158] Add basic custom handler [#91](https://github.com/chef/chef-workstation/pull/91) ([cheeseplus](https://github.com/cheeseplus))
- [SHACK-163] Move ChefDK gem dep into workstation and add shim command [#96](https://github.com/chef/chef-workstation/pull/96) ([tyler-ball](https://github.com/tyler-ball))
- Removing thread ability to print exception information to stdout [#95](https://github.com/chef/chef-workstation/pull/95) ([tyler-ball](https://github.com/tyler-ball))
- [SHACK-145] rename remote connection to target host [#94](https://github.com/chef/chef-workstation/pull/94) ([marcparadise](https://github.com/marcparadise))
- [SHACK-145] Introduce TargetResolver [#93](https://github.com/chef/chef-workstation/pull/93) ([marcparadise](https://github.com/marcparadise))
- Specify repo path to prevent cheffs content from publishing to user home [#90](https://github.com/chef/chef-workstation/pull/90) ([marcparadise](https://github.com/marcparadise))
- Ensure that we return the path of the cached file. [#89](https://github.com/chef/chef-workstation/pull/89) ([marcparadise](https://github.com/marcparadise))
- Correct wrong i18n key for install status [#88](https://github.com/chef/chef-workstation/pull/88) ([marcparadise](https://github.com/marcparadise))
- [SHACK-155] cli integration tests [#87](https://github.com/chef/chef-workstation/pull/87) ([marcparadise](https://github.com/marcparadise))
- [SHACK-141] Lookup cookbooks in repo for remote target execution [#82](https://github.com/chef/chef-workstation/pull/82) ([tyler-ball](https://github.com/tyler-ball))
- [SHACK-154] Create and run with a config file [#86](https://github.com/chef/chef-workstation/pull/86) ([cheeseplus](https://github.com/cheeseplus))
- [SHACK-136] Ensure help works consistently [#79](https://github.com/chef/chef-workstation/pull/79) ([marcparadise](https://github.com/marcparadise))
- Experimental Omnibus APIs we were using got merged to master, update to support that [#85](https://github.com/chef/chef-workstation/pull/85) ([tyler-ball](https://github.com/tyler-ball))
- Temporarily taking ChefDK off the path until its Ruby version is updated [#84](https://github.com/chef/chef-workstation/pull/84) ([tyler-ball](https://github.com/tyler-ball))
- [SHACK-140] Updating our ruby version to 2.5 to be on the latest [#75](https://github.com/chef/chef-workstation/pull/75) ([tyler-ball](https://github.com/tyler-ball))
- [SHACK-143] set the omnibus kitchen config to perform the omnibus build during converge [#74](https://github.com/chef/chef-workstation/pull/74) ([robbkidd](https://github.com/robbkidd))
- [SHACK-127] Converge local recipe on remote target [#71](https://github.com/chef/chef-workstation/pull/71) ([tyler-ball](https://github.com/tyler-ball))
- [SHACK-106] action ui separation [#69](https://github.com/chef/chef-workstation/pull/69) ([marcparadise](https://github.com/marcparadise))
- [SHACK-101] alias support [#73](https://github.com/chef/chef-workstation/pull/73) ([marcparadise](https://github.com/marcparadise))
- [SHACK-122] support -v for version [#72](https://github.com/chef/chef-workstation/pull/72) ([marcparadise](https://github.com/marcparadise))
- re-add lost openssl require [#70](https://github.com/chef/chef-workstation/pull/70) ([marcparadise](https://github.com/marcparadise))
- Remove 404 warning from readme [#68](https://github.com/chef/chef-workstation/pull/68) ([jonsmorrow](https://github.com/jonsmorrow))
- Push changes back to master [#67](https://github.com/chef/chef-workstation/pull/67) ([jonsmorrow](https://github.com/jonsmorrow))
- Remove only if and only run url update on promote. [#66](https://github.com/chef/chef-workstation/pull/66) ([jonsmorrow](https://github.com/jonsmorrow))
- Try promote action to avoid 404s [#65](https://github.com/chef/chef-workstation/pull/65) ([jonsmorrow](https://github.com/jonsmorrow))
- Add note about 404 durning build [#64](https://github.com/chef/chef-workstation/pull/64) ([jonsmorrow](https://github.com/jonsmorrow))
- Fix regex to match new readme formatting [#63](https://github.com/chef/chef-workstation/pull/63) ([jonsmorrow](https://github.com/jonsmorrow))
- Update readme urls before change log [#62](https://github.com/chef/chef-workstation/pull/62) ([jonsmorrow](https://github.com/jonsmorrow))
- Update readme formatting [#61](https://github.com/chef/chef-workstation/pull/61) ([jonsmorrow](https://github.com/jonsmorrow))
- Update expeditor config to properly handle url updates in readme. [#57](https://github.com/chef/chef-workstation/pull/57) ([jonsmorrow](https://github.com/jonsmorrow))
- Fixes the bolding of the NOTE message in README [#60](https://github.com/chef/chef-workstation/pull/60) ([burtlo](https://github.com/burtlo))
- Support for connecting to winrm over ssl [#54](https://github.com/chef/chef-workstation/pull/54) ([marcparadise](https://github.com/marcparadise))
- Try using bash instead of sh in expeditor. [#59](https://github.com/chef/chef-workstation/pull/59) ([jonsmorrow](https://github.com/jonsmorrow))
- Additional rtf tags in license [#56](https://github.com/chef/chef-workstation/pull/56) ([jonsmorrow](https://github.com/jonsmorrow))
- Windows license needs to be rich text. [#53](https://github.com/chef/chef-workstation/pull/53) ([jonsmorrow](https://github.com/jonsmorrow))
- Add dmg resources. [#52](https://github.com/chef/chef-workstation/pull/52) ([jonsmorrow](https://github.com/jonsmorrow))
- windows upload fixes [#49](https://github.com/chef/chef-workstation/pull/49) ([marcparadise](https://github.com/marcparadise))
- Add license and resource templates for each platform [#50](https://github.com/chef/chef-workstation/pull/50) ([jonsmorrow](https://github.com/jonsmorrow))
- Handle common parseable errors [#47](https://github.com/chef/chef-workstation/pull/47) ([marcparadise](https://github.com/marcparadise))
- Make plain-text spinner element avaialble via config [#48](https://github.com/chef/chef-workstation/pull/48) ([marcparadise](https://github.com/marcparadise))
- Update email to support@chef.io [#40](https://github.com/chef/chef-workstation/pull/40) ([marcparadise](https://github.com/marcparadise))
- Need to cd into proper directory for expeditor script to work [#46](https://github.com/chef/chef-workstation/pull/46) ([tyler-ball](https://github.com/tyler-ball))
- Raise an exception when remote CCR fails [#44](https://github.com/chef/chef-workstation/pull/44) ([marcparadise](https://github.com/marcparadise))
- Got some more bug fixes [#43](https://github.com/chef/chef-workstation/pull/43) ([tyler-ball](https://github.com/tyler-ball))
- [SHACK-120] remove alias text [#42](https://github.com/chef/chef-workstation/pull/42) ([marcparadise](https://github.com/marcparadise))
- Bug fixes [#38](https://github.com/chef/chef-workstation/pull/38) ([tyler-ball](https://github.com/tyler-ball))
- Make sure to use proper quoting when replacing version too [#41](https://github.com/chef/chef-workstation/pull/41) ([marcparadise](https://github.com/marcparadise))
- [SHACK-122] Fix quoting in update-version so that it works [#39](https://github.com/chef/chef-workstation/pull/39) ([marcparadise](https://github.com/marcparadise))
- Slight cleanups to error handling [#37](https://github.com/chef/chef-workstation/pull/37) ([marcparadise](https://github.com/marcparadise))
- standard error handling [#36](https://github.com/chef/chef-workstation/pull/36) ([marcparadise](https://github.com/marcparadise))
- use Terminal.output instead of puts [#35](https://github.com/chef/chef-workstation/pull/35) ([marcparadise](https://github.com/marcparadise))
- Move .ci to ci so scripts can be found. [#34](https://github.com/chef/chef-workstation/pull/34) ([jonsmorrow](https://github.com/jonsmorrow))
- [SHACK-107] Specify resource properties on command line [#33](https://github.com/chef/chef-workstation/pull/33) ([tyler-ball](https://github.com/tyler-ball))
- error handling [#31](https://github.com/chef/chef-workstation/pull/31) ([marcparadise](https://github.com/marcparadise))
- Add ci verify script so we controll verification tests. [#32](https://github.com/chef/chef-workstation/pull/32) ([jonsmorrow](https://github.com/jonsmorrow))
- Mask passwords in url output. [#30](https://github.com/chef/chef-workstation/pull/30) ([jonsmorrow](https://github.com/jonsmorrow))
- When remote chef-client run fails we copy over the log [#29](https://github.com/chef/chef-workstation/pull/29) ([tyler-ball](https://github.com/tyler-ball))
- customize windows install for this product [#28](https://github.com/chef/chef-workstation/pull/28) ([marcparadise](https://github.com/marcparadise))
- Adding a Windows Vagrant host for testing [#24](https://github.com/chef/chef-workstation/pull/24) ([tyler-ball](https://github.com/tyler-ball))
- Lets get our Windows Omnibus builds working [#27](https://github.com/chef/chef-workstation/pull/27) ([tyler-ball](https://github.com/tyler-ball))
- Make text and config work reguardless of where the bin resides. [#25](https://github.com/chef/chef-workstation/pull/25) ([jonsmorrow](https://github.com/jonsmorrow))
- We should not update the Gemfile version dependency [#26](https://github.com/chef/chef-workstation/pull/26) ([jaymalasinha](https://github.com/jaymalasinha))
- Changes to make omnibus build complete. [#23](https://github.com/chef/chef-workstation/pull/23) ([jonsmorrow](https://github.com/jonsmorrow))
- Add some dev dependencies to enhance irb [#22](https://github.com/chef/chef-workstation/pull/22) ([marcparadise](https://github.com/marcparadise))
- Add Expeditor config [#21](https://github.com/chef/chef-workstation/pull/21) ([jaymalasinha](https://github.com/jaymalasinha))