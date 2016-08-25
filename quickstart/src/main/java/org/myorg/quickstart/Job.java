package org.myorg.quickstart;

/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import org.apache.flink.api.java.ExecutionEnvironment;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.util.Collector;
import org.bytedeco.javacpp.BytePointer;
import org.bytedeco.javacpp.lept;
import org.bytedeco.javacpp.opencv_core.Mat;
import org.bytedeco.javacpp.tesseract;

import static org.bytedeco.javacpp.lept.pixRead;
import static org.bytedeco.javacpp.opencv_imgcodecs.imwrite;

/**
 * Skeleton for a Flink Job.
 *
 * For a full example of a Flink Job, see the WordCountJob.java file in the
 * same package/directory or have a look at the website.
 *
 * You can also generate a .jar file that you can submit on your Flink
 * cluster.
 * Just type
 * 		mvn clean package
 * in the projects root directory.
 * You will find the jar in
 * 		target/flink-quickstart-0.1-SNAPSHOT-Sample.jar
 *
 */
public class Job {

    public static void main(String[] args) throws Exception {
        // set up the execution environment
        final StreamExecutionEnvironment env = org.apache.flink.streaming.api.environment.StreamExecutionEnvironment
                .getExecutionEnvironment();
        env.getConfig().registerTypeWithKryoSerializer(Mat.class, MatImageSerialize.class);
        env.addSource(new FlinkStreamSource()).flatMap(new FlatMapFn()).writeAsText("testdata");
        env.execute("Flink Video Processing");

    }

    private static class FlatMapFn implements org.apache.flink.api.common.functions.FlatMapFunction<Mat, Object> {
        @Override
        public void flatMap(Mat value, Collector<Object> out) throws Exception {
            tesseract.TessBaseAPI api = new tesseract.TessBaseAPI();
            lept.PIX image = null;
            BytePointer outText = null;
            if (api.Init(".", "ENG") != 0) {
                System.err.println("Could not initialize tesseract.");
                System.exit(1);
            }
            //   if(!(value.empty()) && (value.rows()!=0) ) {
            //   boolean yes = value.empty();
            if (!(value.isNull())) {
                imwrite("OCR_TEST.jpg", value);

                //  pixread
                image = pixRead("OCR_TEST.jpg");
                api.SetImage(image);
                outText = api.GetUTF8Text();
                if (outText == null) {
                    String string = "Nothing to collect";
                    out.collect(string);

                } else {
                    String string = outText.getString();
                    if (!(string.isEmpty())) {
                        //    System.out.println(string);
                        out.collect(string);
                    }

                }

            }
        }
    }
}
