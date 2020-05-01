# Usage

1. Write a [PlantUML][1] file like the sample file [**simple_question.puml**][3]
2. Run `qanda` on your file

  ```shell
  $ docker pull rlespinasse/qanda
  $ docker run -it -v $(PWD):/data rlespinasse/qanda my_qanda_file.puml
  Question 1
  > This docker image is call 'qanda'?
    [X] Yes
    [ ] No
  ```

Want to read more, go to [rlespinasse/qanda][2] on GitHub.

[1]: https://plantuml.com
[2]: https://github.com/rlespinasse/qanda
[3]: https://github.com/rlespinasse/qanda/blob/master/samples/simple_question.puml
