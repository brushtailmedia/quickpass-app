fn main() {
    // Google Play requires native libraries to support 16 KB memory pages for apps
    // targeting Android 15+. NDK r27 links with 4 KB alignment unless told otherwise.
    if std::env::var("CARGO_CFG_TARGET_OS").as_deref() == Ok("android") {
        println!("cargo:rustc-link-arg=-Wl,-z,max-page-size=16384");
    }
    tauri_build::build()
}
