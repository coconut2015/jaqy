/*
 * Copyright (c) 2017-2021 Teradata
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.teradata.jaqy.utils.exp;

import com.teradata.jaqy.JaqyInterpreter;
import com.teradata.jaqy.VariableManager;
import com.teradata.jaqy.interfaces.JaqyResultSet;

/**
 * @author  Heng Yuan
 */
public class BinaryNode extends JSExpNode
{
    private final ExpNode m_left;
    private final ExpNode m_right;
    private final String m_op;

    public BinaryNode (String op, ExpNode left, ExpNode right)
    {
        m_left = left;
        m_right = right;
        m_op = op;
    }

    @Override
    public void bind (JaqyResultSet rs, VariableManager vm, JaqyInterpreter interpreter) throws Exception
    {
        super.bind (rs, vm, interpreter);
        m_left.bind (rs, vm, interpreter);
        m_right.bind (rs, vm, interpreter);
    }

    @Override
    public String toString ()
    {
        return "((" + m_left + ")" + m_op + "(" + m_right + "))";
    }
}
