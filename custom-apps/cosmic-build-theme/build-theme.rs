// Headless equivalent of what COSMIC Settings' Appearance page does on save:
// read the ThemeBuilder, build it, and write the computed Theme — for both
// light and dark. Compiled against the same cosmic-theme as the installed
// COSMIC, so it writes the current (v2) config layout.
use cosmic_config::CosmicConfigEntry;
use cosmic_theme::{Theme, ThemeBuilder};

fn main() -> Result<(), cosmic_config::Error> {
    for is_dark in [false, true] {
        let builder_config = if is_dark {
            ThemeBuilder::dark_config()?
        } else {
            ThemeBuilder::light_config()?
        };
        let builder = match ThemeBuilder::get_entry(&builder_config) {
            Ok(b) => b,
            Err((errs, b)) => {
                for e in errs.into_iter().filter(|e| e.is_err()) {
                    eprintln!("warning: {e}");
                }
                b
            }
        };

        let theme_config = if is_dark {
            Theme::dark_config()?
        } else {
            Theme::light_config()?
        };
        builder.build().write_entry(&theme_config)?;
    }
    println!("Built light and dark COSMIC themes");
    Ok(())
}
