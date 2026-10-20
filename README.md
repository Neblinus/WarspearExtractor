# WarspearExtractor
Extractor/decompactor for the .pak files of Warspear Online.

This tool is a Ruby port of [this guy's tool](https://github.com/MichaelHinrichs/Warspear-Online-Extractor/),
made in C#.

The credit for indentifying the `.pak` format patterns goes to him.<br>
I would also like to thanks him for making this knowledge avaliable.

In a future update, I will adapt the code so that it can be consumed by external code, but until then,<br>
follow the instructions below to learn how to use it.

### Requirements
* Ruby 3.0.7 or greater

### Usage
1. Download the `warspear_extractor.rb` file
2. Open a terminal on the directory where you saved it
3. Type the following command:

```sh
ruby warspear_extractor.rb <path/to/warspear.pak> <path/to/output/directory>
```
4. Where `<path/to/warspear.pak>` and `<path/to/output/directory>` can be both relative or absolute
   paths.
5. Open the output folder and see it worked :)
